// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

/// Represents the type of app installation
public enum PVAppType: String {
    /// Standard non-App Store version
    case standard = "standard"
    /// Lite non-App Store version
    case lite = "lite"
    /// Standard App Store version
    case standardAppStore = "standard.appstore"
    /// Lite App Store version
    case liteAppStore = "lite.appstore"

    /// Determines if this is an App Store build
    public var isAppStore: Bool {
        self == .standardAppStore || self == .liteAppStore
    }

    /// Determines if this is a lite version
    public var isLite: Bool {
        self == .lite || self == .liteAppStore
    }
}

/// Represents a feature flag configuration from JSON
public struct FeatureFlag: Codable, Sendable {
    /// Whether the feature is enabled by default
    public let enabled: Bool
    /// Minimum version required for the feature (optional)
    public let minVersion: String?
    /// Minimum build number required for the feature (optional)
    public let minBuildNumber: String?
    /// List of app types where this feature is allowed
    public let allowedAppTypes: [String]?
    /// Description of the feature
    public let description: String?

    /// Initialize a new feature flag
    /// - Parameters:
    ///   - enabled: Whether the feature is enabled by default
    ///   - minVersion: Minimum version required (optional)
    ///   - minBuildNumber: Minimum build number required (optional)
    ///   - allowedAppTypes: List of allowed app types (optional)
    ///   - description: Description of the feature (optional)
    public init(
        enabled: Bool,
        minVersion: String? = nil,
        minBuildNumber: String? = nil,
        allowedAppTypes: [String]? = nil,
        description: String? = nil
    ) {
        self.enabled = enabled
        self.minVersion = minVersion
        self.minBuildNumber = minBuildNumber
        self.allowedAppTypes = allowedAppTypes
        self.description = description
    }
}

/// Root structure for feature flags JSON
public struct FeatureFlagsConfiguration: Codable, Sendable {
    /// Dictionary of feature flags
    public let features: [String: FeatureFlag]
}

/// Main class for managing feature flags
@MainActor public final class PVFeatureFlags: @unchecked Sendable {
    /// Shared instance for accessing feature flags
    public static let shared = PVFeatureFlags()

    private var configuration: FeatureFlagsConfiguration?
    private let appType: PVAppType
    private let buildNumber: String?
    private let appVersion: String

    /// Initialize with custom parameters
    /// - Parameters:
    ///   - appType: The type of app installation
    ///   - buildNumber: Current build number
    ///   - appVersion: Current app version
    public init(appType: PVAppType? = nil,
                buildNumber: String? = nil,
                appVersion: String? = nil) {
        self.appType = appType ?? PVFeatureFlags.getCurrentAppType()
        self.buildNumber = buildNumber ?? PVFeatureFlags.getCurrentBuildNumber()
        self.appVersion = appVersion ?? PVFeatureFlags.getCurrentAppVersion()
    }

    /// Initialize with a pre-loaded configuration (for testing)
    internal convenience init(
        configuration: FeatureFlagsConfiguration,
        appType: PVAppType? = nil,
        buildNumber: String? = nil,
        appVersion: String? = nil
    ) {
        self.init(appType: appType, buildNumber: buildNumber, appVersion: appVersion)
        self.configuration = configuration
    }

    /// Set configuration directly (for testing)
    internal func setConfiguration(_ configuration: FeatureFlagsConfiguration) {
        self.configuration = configuration
    }

    /// Load feature flags from a JSON file URL
    /// - Parameter url: URL to the JSON configuration
    /// - Returns: Async task that loads and parses the configuration
    public func loadConfiguration(from url: URL) async throws {
        let (data, _) = try await URLSession.shared.data(from: url)
        configuration = try JSONDecoder().decode(FeatureFlagsConfiguration.self, from: data)
        print("Loaded confuration. \(configuration?.features.count ?? 0) features")
    }

    /// Check if a feature is enabled
    /// - Parameter featureKey: The key of the feature to check
    /// - Returns: Boolean indicating if the feature is enabled
    public func isEnabled(_ featureKey: String) -> Bool {
        guard let feature = configuration?.features[featureKey] else {
            print("Error: Feature Key \(featureKey) not found")
            return false
        }

        // Check app type restrictions
        if let allowedTypes = feature.allowedAppTypes,
           !allowedTypes.contains(appType.rawValue) {
            print("Feature: \(featureKey) is not allowed for app type \(appType.rawValue)")
            return false
        }

        // Check build number requirement
        if let minBuild = feature.minBuildNumber,
           let currentBuild = buildNumber,
           compareVersions(currentBuild, minBuild) < 0 {
            print("Feature: \(featureKey) is not allowed for build \(currentBuild)")
            return false
        }

        // Check version requirement
        if let minVersion = feature.minVersion,
           compareVersions(appVersion, minVersion) < 0 {
            print("Feature: \(featureKey) is not allowed for version \(appVersion)")
            return false
        }
        print("Feature: \(featureKey) is enabled")
        return feature.enabled
    }

    /// Helper function to compare version strings
    private func compareVersions(_ version1: String, _ version2: String) -> Int {
        let components1 = version1.split(separator: ".")
        let components2 = version2.split(separator: ".")

        let maxLength = max(components1.count, components2.count)

        for i in 0..<maxLength {
            let num1 = i < components1.count ? Int(components1[i]) ?? 0 : 0
            let num2 = i < components2.count ? Int(components2[i]) ?? 0 : 0

            if num1 < num2 {
                return -1
            } else if num1 > num2 {
                return 1
            }
        }
        return 0
    }

    /// Get current app type from Info.plist
    public static func getCurrentAppType() -> PVAppType {
        let appTypeString = Bundle.main.infoDictionary?["PVAppType"] as? String ?? "standard"
        return PVAppType(rawValue: appTypeString) ?? .standard
    }

    /// Get current build number from Info.plist
    public static func getCurrentBuildNumber() -> String? {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }

    /// Get current app version from Info.plist
    public static func getCurrentAppVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    /// Get all available feature flags and their current state (debug only)
    @MainActor public func getAllFeatureFlags() -> [(key: String, flag: FeatureFlag, enabled: Bool)] {
        guard let configuration = configuration else {
            print("No configuration available")
            return []
        }

        let allFlags = configuration.features.map { key, flag in
            // Get the base enabled state from the flag
            let baseEnabled = flag.enabled

            // Get any debug override
            let debugEnabled = PVFeatureFlagsManager.shared.debugOverrides[key]

            // Get restrictions
            let restrictions = getFeatureRestrictions(key)

            // Calculate effective enabled state
            let effectiveEnabled = debugEnabled ?? (baseEnabled && restrictions.isEmpty)

            print("Flag \(key): baseEnabled=\(baseEnabled), debugEnabled=\(String(describing: debugEnabled)), restrictions=\(restrictions), effectiveEnabled=\(effectiveEnabled)")

            return (key: key, flag: flag, enabled: effectiveEnabled)
        }

        print("All flags: \(allFlags)")
        return allFlags
    }

    /// Get feature restrictions for debugging
    @MainActor public func getFeatureRestrictions(_ featureKey: String) -> [String] {
        guard let feature = configuration?.features[featureKey] else { return ["Feature not found"] }

        var restrictions: [String] = []

        // Check app type restrictions
        if let allowedTypes = feature.allowedAppTypes,
           !allowedTypes.contains(PVFeatureFlags.getCurrentAppType().rawValue) {
            restrictions.append("App type \(PVFeatureFlags.getCurrentAppType().rawValue) not allowed")
        }

        // Check build number requirement
        if let minBuild = feature.minBuildNumber,
           let currentBuild = PVFeatureFlags.getCurrentBuildNumber(),
           compareVersions(currentBuild, minBuild) < 0 {
            restrictions.append("Build \(currentBuild) below minimum \(minBuild)")
        }

        // Check version requirement
        if let minVersion = feature.minVersion,
           compareVersions(PVFeatureFlags.getCurrentAppVersion(), minVersion) < 0 {
            restrictions.append("Version \(PVFeatureFlags.getCurrentAppVersion()) below minimum \(minVersion)")
        }

        return restrictions
    }

    /// Set configuration directly (for testing and debug purposes)
    @MainActor public func setDebugConfiguration(features: [String: FeatureFlag]) {
        self.configuration = FeatureFlagsConfiguration(features: features)
    }
}

/// Observable class for managing feature flags in SwiftUI
@MainActor public final class PVFeatureFlagsManager: ObservableObject, @unchecked Sendable {
    /// Shared instance for accessing feature flags
    public static let shared = PVFeatureFlagsManager()

    /// The underlying feature flags implementation
    private let featureFlags: PVFeatureFlags

    /// Dictionary of cached feature states
    @Published private var featureStates: [String: Bool] = [:]

    /// Dictionary to store debug overrides - persisted in UserDefaults
    public var debugOverrides: [String: Bool] {
        get {
            UserDefaults.standard.dictionary(forKey: "PVFeatureFlagsDebugOverrides") as? [String: Bool] ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "PVFeatureFlagsDebugOverrides")
            objectWillChange.send()
        }
    }

    /// Dictionary to store remote feature flags
    private var remoteFlags: [String: Bool] = [:]

    private init() {
        self.featureFlags = PVFeatureFlags()
        // Load any persisted debug overrides
        if let savedOverrides = UserDefaults.standard.dictionary(forKey: "PVFeatureFlagsDebugOverrides") as? [String: Bool] {
            print("Loaded debug overrides from UserDefaults: \(savedOverrides)")
        }
    }

    /// Initialize with custom parameters for testing
    init(featureFlags: PVFeatureFlags) {
        self.featureFlags = featureFlags
    }

    /// Load feature flags from a JSON file URL
    /// - Parameter url: URL to the JSON configuration
    /// - Returns: Async task that loads and parses the configuration
    public func loadConfiguration(from url: URL) async throws {
        do {
            try await featureFlags.loadConfiguration(from: url)
            print("Loaded configuration from \(url)")
            print("Current features: \(featureFlags.getAllFeatureFlags())")
            updateFeatureStates()
        } catch {
            print("Failed to load configuration from \(url): \(error)")
            throw error
        }
    }

    /// Whether the inAppFreeROMs feature is enabled
    public var inAppFreeROMs: Bool {
        /// Check debug override first
        if let override = debugOverrides["inAppFreeROMs"] {
            print("Debug override active for inAppFreeROMs: \(override)")
            return override
        }

        /// Fall back to main feature flags system
        let enabled = featureFlags.isEnabled("inAppFreeROMs")
        print("No debug override, using feature flags system value for inAppFreeROMs: \(enabled)")
        return enabled
    }

    /// Whether the romPathMigrator feature is enabled
    public var romPathMigrator: Bool {
        /// Check debug override first
        if let override = debugOverrides["romPathMigrator"] {
            print("Debug override active for romPathMigrator: \(override)")
            return override
        }

        /// Fall back to main feature flags system
        let enabled = featureFlags.isEnabled("romPathMigrator")
        print("No debug override, using feature flags system value for romPathMigrator: \(enabled)")
        return enabled
    }

    /// Set a debug override for a feature flag
    public func setDebugOverride(feature: String, enabled: Bool) {
        print("Setting debug override for \(feature) to: \(enabled)")
        var currentOverrides = debugOverrides
        currentOverrides[feature] = enabled
        debugOverrides = currentOverrides
        print("Current debug overrides: \(debugOverrides)")
        // Update cached states
        updateFeatureStates()
    }

    /// Updates the cached feature states
    private func updateFeatureStates() {
        // Check debug override first
        if let override = debugOverrides["inAppFreeROMs"] {
            featureStates["inAppFreeROMs"] = override
        } else {
            featureStates["inAppFreeROMs"] = featureFlags.isEnabled("inAppFreeROMs")
        }
    }

    /// Check if a feature is enabled
    /// - Parameter featureKey: The key of the feature to check
    /// - Returns: Boolean indicating if the feature is enabled
    public func isEnabled(_ featureKey: String) -> Bool {
        // Check debug override first
        if let override = debugOverrides[featureKey] {
            print("Debug override for \(featureKey): \(override)")
            return override
        }

        // Fall back to cached state or feature flags system
        if let cachedState = featureStates[featureKey] {
            return cachedState
        }
        let enabled = featureFlags.isEnabled(featureKey)
        featureStates[featureKey] = enabled
        return enabled
    }

    /// Clear all debug overrides
    public func clearDebugOverrides() {
        print("Clearing all debug overrides")
        debugOverrides = [:]
        updateFeatureStates()
    }

    /// Clear specific debug override
    public func clearDebugOverride(for feature: String) {
        print("Clearing debug override for \(feature)")
        var currentOverrides = debugOverrides
        currentOverrides.removeValue(forKey: feature)
        debugOverrides = currentOverrides
        updateFeatureStates()
    }

    /// Update remote flags
    public func updateRemoteFlags(_ flags: [String: Bool]) {
        remoteFlags = flags
    }

    /// Non-actor-isolated version of feature check for use in UIKit
    public nonisolated func isFeatureEnabled(_ featureKey: String) -> Bool {
        // Since this is nonisolated, we need to be careful about thread safety
        DispatchQueue.main.sync {
            if let override = debugOverrides[featureKey] {
                print("Debug override for \(featureKey): \(override)")
                return override
            }

            if let cachedState = featureStates[featureKey] {
                return cachedState
            }

            let enabled = featureFlags.isEnabled(featureKey)
            featureStates[featureKey] = enabled
            return enabled
        }
    }

    /// Get feature restrictions (wrapper for PVFeatureFlags method)
    public func getFeatureRestrictions(_ featureKey: String) -> [String] {
        return featureFlags.getFeatureRestrictions(featureKey)
    }

    /// Set debug configuration (wrapper for PVFeatureFlags method)
    public func setDebugConfiguration(features: [String: FeatureFlag]) {
        featureFlags.setDebugConfiguration(features: features)
        // Update cached states after setting new configuration
        updateFeatureStates()
        // Notify observers
        objectWillChange.send()
    }

    /// Get all feature flags (wrapper for PVFeatureFlags method)
    public func getAllFeatureFlags() -> [(key: String, flag: FeatureFlag, enabled: Bool)] {
        return featureFlags.getAllFeatureFlags()
    }
}

// MARK: - Environment Values
#if canImport(SwiftUI)
import SwiftUI

private struct PVFeatureFlagsManagerKey: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue = PVFeatureFlagsManager.shared
}

extension EnvironmentValues {
    /// Access to feature flags in SwiftUI views
    public var featureFlags: PVFeatureFlagsManager {
        get { self[PVFeatureFlagsManagerKey.self] }
        set { self[PVFeatureFlagsManagerKey.self] = newValue }
    }
}
#endif