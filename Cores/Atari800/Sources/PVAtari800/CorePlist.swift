//
//  CorePlist.swift
//
//
//  Created by Joseph Mattiello on 6/21/24.
//

import Foundation
import PVCoreBridge
import PVLogging
import PVPlists

#if SWIFT_PACKAGE
public extension PVBundleFinder {
    static public var PVAtari800Module: Bundle { Bundle.module }
    static public var PVAtari800Bundle: Bundle { Bundle(for: PVAtari800.self) }
}
#else
public extension PVBundleFinder {
    static public var ATR800GameCoreBundle: Bundle { Bundle(for: PVAtari800.self) }
}
#endif

extension PVAtari800: EmulatorCoreInfoPlistProvider {

    /*
     <?xml version="1.0" encoding="UTF-8"?>
     <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
     <plist version="1.0">
     <dict>
     <key>PVCoreIdentifier</key>
     <string>com.provenance.core.atari800</string>
     <key>PVPrincipleClass</key>
     <string>ATR800GameCore</string>
     <key>PVSupportedSystems</key>
     <array>
     <string>com.provenance.5200</string>
     <string>com.provenance.8bit</string>
     </array>
     <key>PVProjectName</key>
     <string>Atari 800</string>
     <key>PVProjectURL</key>
     <string>https://atari800.github.io</string>
     <key>PVProjectVersion</key>
     <string>3.1.0</string>
     </dict>
     </plist>
     */
    static var defaultPlist: EmulatorCoreInfoPlist { EmulatorCoreInfoPlist.init(
        identifier: "com.provenance.atari800",
        principleClass: "PVAtari800Swift.ATR800GameCore", // ATR800GameCore?
        supportedSystems: ["com.provenance.5200", "com.provenance.8bit"],
        projectName: "Atari 800",
        projectURL: "https://atari800.github.io",
        projectVersion: "3.1.0"
    )}

    public static let resourceBundle: Bundle = Bundle.module

    public static var corePlistFromBundle: EmulatorCoreInfoPlist {
        guard let plistPath = Bundle.module.url(forResource: "Core", withExtension: "plist") else {
            ELOG("Could not locate Core.plist")
            return defaultPlist
        }

        guard let data = try? Data(contentsOf: plistPath) else {
            ELOG("Could not read Core.plist")
            return defaultPlist
        }

        guard let plistObject = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            ELOG("Could not generate parse Core.plist")
            return defaultPlist
        }

        guard let corePlist = EmulatorCoreInfoPlist.init(fromInfoDictionary: plistObject) else {
            ELOG("Could not generate EmulatorCoreInfoPlist from Core.plist")
            return defaultPlist
        }

        return corePlist
    }

    /// Note: CorePlist is an enum generated by SwiftGen with a custom stencil
    /// Change the swiftgen config to the local path to see the outputs and tweak
    @objc(corePlist)
    public static var corePlist: EmulatorCoreInfoPlist { CorePlist.corePlist }

    @objc
    public var corePlist: EmulatorCoreInfoPlist { Self.corePlist }
}

