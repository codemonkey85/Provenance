// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription
import Foundation

let cSettings_retroarch: [CSetting] = [[
    "audio",
    "bluetooth",
    "camera",
    "chevos",
    "cores",
    "ctr",
    "deps",
    "frontend",
    "gfx",
    "input",
    "griffin",
    "libretro-common",
    "libretro-common/include"
].map { CSetting.headerSearchPath("../../RetroArch/\($0)") }, cSettings_DEFINES].flatMap { $0 }

let package = Package(
    name: "PVRetroArch",
    platforms: [
        .iOS("15.5"),
        .tvOS("15.4"),
        .watchOS(.v9),
        .macOS(.v11),
        .macCatalyst(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "PVRetroArch",
            targets: ["PVRetroArch"]),
        .library(
            name: "PVRetroArch-Dynamic",
            type: .dynamic,
            targets: ["PVRetroArch"]),
        .library(
            name: "PVRetroArch-Static",
            type: .static,
            targets: ["PVRetroArch"]),
    ],
    
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "PVLogging", path: "../PVLogging/"),
        .package(name: "PVSupport", path: "../PVSupport/"),
        .package(name: "PVEmulatorCore", path: "../PVEmulatorCore/"),
        .package(name: "PVObjCUtils", path: "../PVObjCUtils/"),
        .package(name: "PVAudio", path: "../PVAudio/"),
        .package(name: "SSZipArchive", path: "./RetroArch/ZipArchive"),
    ],
    
    // MARK: - Targets
    targets: [
        
        // MARK: - iOS Code
        
        // ------------------------------------
        // MARK: - PVRetroArchSwift
        // ------------------------------------
        .target (
            name: "PVRetroArchSwift",
            dependencies: [
                "PVRetroArch"
            ],
            path: "RetroArch/PVRetroArchCore/Swift"
        ),

        // ------------------------------------
        // MARK: - PVRetroArch
        // ------------------------------------
            
        .target(
            name: "PVRetroArch",
            dependencies: [
                "PVEmulatorCore",
                "PVObjCUtils",
                "PVSupport",
                "PVAudio",
                "PVLogging",
                "libretroarch",
                "lhasa",
                "LzhArchive",
                "RarArchive",
                .product(name: "ZipArchive", package: "SSZipArchive")
            ],
            path: "RetroArch/PVRetroArchCore/Core",
            sources: [
                "PVRetroArch.mm",
                "PVRetroArchCore+Archive+AppleII.m",
                "PVRetroArchCore+Archive+MAME.m",
                "PVRetroArchCore+Archive+PC98.m",
                //                    "PVRetroArchCore+Archive.h",
                "PVRetroArchCore+Archive.m",
                //                    "PVRetroArchCore+Audio.h",
                "PVRetroArchCore+Audio.mm",
                "PVRetroArchCore+Cheats.mm",
                "PVRetroArchCore+Controls+3DO.m",
                "PVRetroArchCore+Controls+DS.m",
                "PVRetroArchCore+Controls+Dreamcast.m",
                "PVRetroArchCore+Controls+GB.m",
                "PVRetroArchCore+Controls+GBA.m",
                "PVRetroArchCore+Controls+Genesis.m",
                "PVRetroArchCore+Controls+MAME.m",
                "PVRetroArchCore+Controls+N64.m",
                "PVRetroArchCore+Controls+NES.m",
                "PVRetroArchCore+Controls+NeoGeo.m",
                "PVRetroArchCore+Controls+PCE.m",
                "PVRetroArchCore+Controls+PSP.m",
                "PVRetroArchCore+Controls+PSX.m",
                "PVRetroArchCore+Controls+SNES.m",
                "PVRetroArchCore+Controls+Saturn.m",
                //                    "PVRetroArchCore+Controls.h",
                "PVRetroArchCore+Controls.m",
                "PVRetroArchCore+RetroArchUI.m",
                //                    "PVRetroArchCore+Saves.h",
                "PVRetroArchCore+Saves.mm",
                //                    "PVRetroArchCore+Video.h",
                "PVRetroArchCore+Video.mm",
                //                    "PVRetroArchCore.h",
                "PVRetroArchCore.mm",
                "Shaders.metal",
                //                    "apple_platform.h",
                //                    "cocoa_common.h",
                "cocoa_common.m",
                "cocoa_gl_ctx.m",
                "cocoa_vk_ctx.m",
                "dylib.c",
                "menu_pipeline.metal",
                "metal.m",
                "platform_darwin.m",
                "runloop.c",
                "vulkan_common.c",
                //                    "vulkan_common.h",
                //                    "vulkan_metal.h",
            ],
            publicHeadersPath: ".",
            cSettings: [
                .define("LIBRETRO", to: "1"),
                .headerSearchPath("include"),
                .headerSearchPath("../PVSupport/include"),
                .headerSearchPath("../PVEmulatorCoreObjC/include"),
                .headerSearchPath("./PVRetroArch"),
                .headerSearchPath("./PVRetroArchCore"),
                .headerSearchPath("../PVRetroArchCore/Core"),
                .headerSearchPath("."),
                .headerSearchPath("../Retroarch/pkg/apple"),
                .headerSearchPath("../Retroarch/pkg"),
                .headerSearchPath("../RetroArch/ui/drivers"),
                .headerSearchPath("../Retroarch/ui/drivers/cocoa"),
                .headerSearchPath("../Retroarch/pkg/apple/iOS"),
                .headerSearchPath("../Retroarch/pkg/apple/WebServer/GCDWebUploader"),
                .headerSearchPath("../Retroarch/"),
                .headerSearchPath("../Retroarch/libretro-common/include"),
                .headerSearchPath("../Retroarch/libretro-common/include/compat/zlib"),
                .headerSearchPath("../Retroarch/deps/stb"),
                .headerSearchPath("../Retroarch/deps/rcheevos/include"),
                .headerSearchPath("../Retroarch/deps"),
                .headerSearchPath("../Retroarch/libretro-common/include"),
                .headerSearchPath("../RetroArch/gfx/drivers_context"),
                .headerSearchPath("../Retroarch/gfx"),
                .headerSearchPath("../RetroArch/gfx/include/"),
                .headerSearchPath("../RetroArch/pkg/apple/WebServer/GCDWebUploader"),
                .headerSearchPath("../RetroArch/pkg/apple/WebServer/GCDWebServer/Responses"),
                .headerSearchPath("../RetroArch/pkg/apple/WebServer/GCDWebServer/Requests"),
                .headerSearchPath("../RetroArch/pkg/apple/WebServer/GCDWebServer/Core"),
                .headerSearchPath("../RetroArch/pkg/apple/WebServer"),
                .headerSearchPath("../RetroArch/gfx/common/"),
                .headerSearchPath("../RetroArch/gfx/common/metal/"),
                .headerSearchPath("../RetroArch/gfx/drivers/"),
                .headerSearchPath("./RetroArch/frontend/drivers"),
                .headerSearchPath("./RetroArch/input"),
                .headerSearchPath("./RetroArch/input/drivers"),
                .headerSearchPath("./RetroArch/libretro-common/include"),
                .headerSearchPath("./RetroArch/input/include/GameController/"),
                .headerSearchPath("./PVRetroArchCore/Core"),
                .headerSearchPath("./PVRetroArchCore/Archive/LzhArchive"),
                .headerSearchPath("./PVRetroArchCore/Archive/ZipArchive/SSZipArchive"),
                .headerSearchPath("./PVRetroArchCore/Archive/RarArchive"),
                .headerSearchPath("../RetroArch/deps/glslang"),
                .headerSearchPath("../RetroArch/deps/SPIRV-Cross"),
                .headerSearchPath("../RetroArch/deps/glslang/glslang/glslang/Public"),
                .headerSearchPath("../RetroArch/deps/glslang/glslang/glslang/OSDependent/Unix"),
                .headerSearchPath("../RetroArch/deps/glslang/glslang/SPIRV"),
                .headerSearchPath("../RetroArch/deps/glslang/glslang/glslang/MachineIndependent"),
            ],
            swiftSettings: pvemulatorCoreSwiftFlags,
            linkerSettings: [
                //              "-Wl,-segalign,4000"
                .linkedFramework("GameController", .when(platforms: [.iOS, .tvOS, .macCatalyst, .macOS])),
                .linkedFramework("CoreGraphics", .when(platforms: [.iOS, .tvOS, .macCatalyst, .macOS])),
                .linkedFramework("UIKit", .when(platforms: [.iOS, .tvOS, .macCatalyst, .macOS])),
            ]),
        
        // ------------------------------------
        // MARK: - libretroarch
        // ------------------------------------
        .target (
            name: "libretroarch",
            path: "RetroArch/PVRetroArchCore/retroarch/",
            sources: [
                "griffin.c",
                "griffin.m",
                "griffin_slang.cpp",
                "griffin_cpp.cpp"
            ],
            publicHeadersPath: "",
            cSettings: cSettings_retroarch,
            linkerSettings: [
                .linkedLibrary("z"),
                .linkedLibrary("iconv")
            ]
        ),
        // MARK: - C compression Libs
        
        // ------------------------------------
        // MARK: - LzhArchive
        // ------------------------------------
        .target (
            name: "LzhArchive",
            path: "RetroArch/LzhArchive/",
            sources: [
                "extract.c",
                "utf8.c",
                "LzhArchive.m",
            ],
            cSettings: [
                .headerSearchPath("../lhasa/"),
                .headerSearchPath("../lhasa/src"),
                .headerSearchPath("../lhasa/lib/"),
                .headerSearchPath("../lhasa/lib/public/"),
                .headerSearchPath("../"),
                .headerSearchPath("../RetroArch"),
                .headerSearchPath("../RetroArch/libretro-common/"),
                .headerSearchPath("../RetroArch/libretro-common/include")
            ],
            linkerSettings: [
                .linkedLibrary("lzma")
            ]
        ),
        
        // ------------------------------------
        // MARK: - lhasa
        // ------------------------------------
        .target (
            name: "lhasa",
            dependencies: [
                "LzhArchive"
            ],
            path: "RetroArch/lhasa/",
            sources: Sources.lhasa,
            publicHeadersPath: "lib/public",
            cSettings: [
                .headerSearchPath("./"),
                .headerSearchPath("./lib"),
                .headerSearchPath("./lib/public"),
                .headerSearchPath("./src")
                
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Wl,-segalign,4000"
                ])
            ]
        ),
    
        // ------------------------------------
        // MARK: - RarArchive
        // ------------------------------------
        .target (
            name: "RarArchive",
            path: "RetroArch/RarArchive",
            cSettings: [
                .headerSearchPath("../UnrarKit/Libraries/unrar")
            ],
            linkerSettings: [
                .linkedLibrary("unrar")
            ]
        )
    ],
    swiftLanguageModes: [.v5],
    cLanguageStandard: .gnu17,
    cxxLanguageStandard: .cxx20
)

let pvemulatorCoreSwiftFlags: [SwiftSetting] = [
    .define("LIBRETRO"),
    .interoperabilityMode(.Cxx)
]

let cSettings_DEFINES: [CSetting] = [
    .unsafeFlags([
        "-Qunused-arguments",
        "-Xanalyzer", "-analyzer-disable-all-checks"
    ]),
    .define("DONT_WANT_ARM_OPTIMIZATIONS", .when(configuration: .debug)),
    .define("ENABLE_HLSL", .when(configuration: .debug)),
    .define("GLES_SILENCE_DEPRECATION", .when(configuration: .debug)),
    .define("GLSLANG_OSINCLUDE_UNIX", .when(configuration: .debug)),
    .define("HAVE_7ZIP", .when(configuration: .debug)),
    .define("HAVE_AUDIOMIXER", .when(configuration: .debug)),
    .define("HAVE_BTSTACK", .when(configuration: .debug)),
    .define("HAVE_BUILTINGLSLANG", .when(configuration: .debug)),
    .define("HAVE_BUILTINMINIUPNPC", .when(configuration: .debug)),
    .define("HAVE_CC_RESAMPLER", .when(configuration: .debug)),
    .define("HAVE_CHEATS", .when(configuration: .debug)),
    .define("HAVE_CHEEVOS", .when(configuration: .debug)),
    .define("HAVE_COCOATOUCH", .when(configuration: .debug)),
    .define("HAVE_COCOA_METAL", .when(configuration: .debug)),
    .define("HAVE_CONFIGFILE", .when(configuration: .debug)),
    .define("HAVE_COREAUDIO", .when(configuration: .debug)),
    .define("HAVE_DYNAMIC", .when(configuration: .debug)),
    .define("HAVE_FILTERS_BUILTIN", .when(configuration: .debug)),
    .define("HAVE_GFX_WIDGETS", .when(configuration: .debug)),
    .define("HAVE_GLSL", .when(configuration: .debug)),
    .define("HAVE_GLSLANG", .when(configuration: .debug)),
    .define("HAVE_GRIFFIN", .when(configuration: .debug)),
    .define("HAVE_HID", .when(configuration: .debug)),
    .define("HAVE_IFINFO", .when(configuration: .debug)),
    .define("HAVE_IMAGEVIEWER", .when(configuration: .debug)),
    .define("HAVE_IOS_CUSTOMKEYBOARD", .when(configuration: .debug)),
    .define("HAVE_IOS_SWIFT", .when(configuration: .debug)),
    .define("HAVE_IOS_TOUCHMOUSE", .when(configuration: .debug)),
    .define("HAVE_KEYMAPPER", .when(configuration: .debug)),
    .define("HAVE_LANGEXTRA", .when(configuration: .debug)),
    .define("HAVE_LIBRETRODB", .when(configuration: .debug)),
    .define("HAVE_MAIN", .when(configuration: .debug)),
    .define("HAVE_MATERIALUI", .when(configuration: .debug)),
    .define("HAVE_MENU", .when(configuration: .debug)),
    .define("HAVE_METAL", .when(configuration: .debug)),
    .define("HAVE_MFI", .when(configuration: .debug)),
    .define("HAVE_MINIUPNPC", .when(configuration: .debug)),
    .define("HAVE_NETPLAYDISCOVERY", .when(configuration: .debug)),
    .define("HAVE_NETWORKGAMEPAD", .when(configuration: .debug)),
    .define("HAVE_NETWORKING", .when(configuration: .debug)),
    .define("HAVE_ONLINE_UPDATER", .when(configuration: .debug)),
    .define("HAVE_OPENGL", .when(configuration: .debug)),
    .define("HAVE_OPENGLES", .when(configuration: .debug)),
    .define("HAVE_OPENGLES3", .when(configuration: .debug)),
    .define("HAVE_OVERLAY", .when(configuration: .debug)),
    .define("HAVE_OZONE", .when(configuration: .debug)),
    .define("HAVE_PATCH", .when(configuration: .debug)),
    .define("HAVE_RBMP", .when(configuration: .debug)),
    .define("HAVE_REWIND", .when(configuration: .debug)),
    .define("HAVE_RGUI", .when(configuration: .debug)),
    .define("HAVE_RJPEG", .when(configuration: .debug)),
    .define("HAVE_RPNG", .when(configuration: .debug)),
    .define("HAVE_RTGA", .when(configuration: .debug)),
    .define("HAVE_RUNAHEAD", .when(configuration: .debug)),
    .define("HAVE_RWAV", .when(configuration: .debug)),
    .define("HAVE_SCREENSHOTS", .when(configuration: .debug)),
    .define("HAVE_SHADERPIPELINE", .when(configuration: .debug)),
    .define("HAVE_SLANG", .when(configuration: .debug)),
    .define("HAVE_SPIRV_CROSS", .when(configuration: .debug)),
    .define("HAVE_STB_FONT", .when(configuration: .debug)),
    .define("HAVE_STB_VORBIS", .when(configuration: .debug)),
    .define("HAVE_THREADS", .when(configuration: .debug)),
    .define("HAVE_TRANSLATE", .when(configuration: .debug)),
    .define("HAVE_UPDATE_ASSETS", .when(configuration: .debug)),
    .define("HAVE_UPDATE_CORE_INFO", .when(configuration: .debug)),
    .define("HAVE_VIDEO_LAYOUT", .when(configuration: .debug)),
    .define("HAVE_VULKAN", .when(configuration: .debug)),
    .define("HAVE_XMB", .when(configuration: .debug)),
    .define("HAVE_ZLIB", .when(configuration: .debug)),
    .define("INLINE", to: "inline", .when(configuration: .debug)),
    .define("IOS", .when(configuration: .debug)),
    .define("RARCH_INTERNAL", .when(configuration: .debug)),
    .define("RARCH_MOBILE", .when(configuration: .debug)),
    .define("RC_DISABLE_LUA", .when(configuration: .debug)),
    .define("WANT_GLSLANG", .when(configuration: .debug)),
    .define("_7ZIP_ST", .when(configuration: .debug)),
    .define("_LZMA_UINT32_IS_ULONG", .when(configuration: .debug)),
    .define("__LIBRETRO__", .when(configuration: .debug)),
    .define("HAVE_OPENGLES3", .when(configuration: .debug)),
    .define("HAVE_IOS_CUSTOMKEYBOARD", .when(configuration: .debug)),
    .define("HAVE_IOS_TOUCHMOUSE", .when(configuration: .debug)),
    .define("HAVE_IOS_SWIFT", .when(configuration: .debug)),
    .define("TARGET_OS_IPHONE", to: "1", .when(configuration: .debug)),
    .define("HAVE_VULKAN", to: "1", .when(configuration: .debug)),
    .define("HAVE_SWRESAMPLE", to: "1", .when(configuration: .debug)),
    .define("VULKAN_HDR_SWAPCHAIN", to: "1", .when(configuration: .debug)),
    .define("HAVE_SHADERPIPELINE", .when(configuration: .debug)),
    
        .define("NDEBUG", .when(configuration: .release)),
    .define("DONT_WANT_ARM_OPTIMIZATIONS", .when(configuration: .release)),
    .define("ENABLE_HLSL", .when(configuration: .release)),
    .define("GLES_SILENCE_DEPRECATION", .when(configuration: .release)),
    .define("GLSLANG_OSINCLUDE_UNIX", .when(configuration: .release)),
    .define("HAVE_7ZIP", .when(configuration: .release)),
    .define("HAVE_AUDIOMIXER", .when(configuration: .release)),
    .define("HAVE_BTSTACK", .when(configuration: .release)),
    .define("HAVE_BUILTINGLSLANG", .when(configuration: .release)),
    .define("HAVE_BUILTINMINIUPNPC", .when(configuration: .release)),
    .define("HAVE_CC_RESAMPLER", .when(configuration: .release)),
    .define("HAVE_CHEATS", .when(configuration: .release)),
    .define("HAVE_CHEEVOS", .when(configuration: .release)),
    .define("HAVE_COCOATOUCH", .when(configuration: .release)),
    .define("HAVE_COCOA_METAL", .when(configuration: .release)),
    .define("HAVE_CONFIGFILE", .when(configuration: .release)),
    .define("HAVE_COREAUDIO", .when(configuration: .release)),
    .define("HAVE_DYNAMIC", .when(configuration: .release)),
    .define("HAVE_FILTERS_BUILTIN", .when(configuration: .release)),
    .define("HAVE_GFX_WIDGETS", .when(configuration: .release)),
    .define("HAVE_GLSL", .when(configuration: .release)),
    .define("HAVE_GLSLANG", .when(configuration: .release)),
    .define("HAVE_GRIFFIN", .when(configuration: .release)),
    .define("HAVE_HID", .when(configuration: .release)),
    .define("HAVE_IFINFO", .when(configuration: .release)),
    .define("HAVE_IMAGEVIEWER", .when(configuration: .release)),
    .define("HAVE_IOS_CUSTOMKEYBOARD", .when(configuration: .release)),
    .define("HAVE_IOS_SWIFT", .when(configuration: .release)),
    .define("HAVE_IOS_TOUCHMOUSE", .when(configuration: .release)),
    .define("HAVE_KEYMAPPER", .when(configuration: .release)),
    .define("HAVE_LANGEXTRA", .when(configuration: .release)),
    .define("HAVE_LIBRETRODB", .when(configuration: .release)),
    .define("HAVE_MAIN", .when(configuration: .release)),
    .define("HAVE_MATERIALUI", .when(configuration: .release)),
    .define("HAVE_MENU", .when(configuration: .release)),
    .define("HAVE_METAL", .when(configuration: .release)),
    .define("HAVE_MFI", .when(configuration: .release)),
    .define("HAVE_MINIUPNPC", .when(configuration: .release)),
    .define("HAVE_NETPLAYDISCOVERY", .when(configuration: .release)),
    .define("HAVE_NETWORKGAMEPAD", .when(configuration: .release)),
    .define("HAVE_NETWORKING", .when(configuration: .release)),
    .define("HAVE_ONLINE_UPDATER", .when(configuration: .release)),
    .define("HAVE_OPENGL", .when(configuration: .release)),
    .define("HAVE_OPENGLES", .when(configuration: .release)),
    .define("HAVE_OPENGLES3", .when(configuration: .release)),
    .define("HAVE_OVERLAY", .when(configuration: .release)),
    .define("HAVE_OZONE", .when(configuration: .release)),
    .define("HAVE_PATCH", .when(configuration: .release)),
    .define("HAVE_RBMP", .when(configuration: .release)),
    .define("HAVE_REWIND", .when(configuration: .release)),
    .define("HAVE_RGUI", .when(configuration: .release)),
    .define("HAVE_RJPEG", .when(configuration: .release)),
    .define("HAVE_RPNG", .when(configuration: .release)),
    .define("HAVE_RTGA", .when(configuration: .release)),
    .define("HAVE_RUNAHEAD", .when(configuration: .release)),
    .define("HAVE_RWAV", .when(configuration: .release)),
    .define("HAVE_SCREENSHOTS", .when(configuration: .release)),
    .define("HAVE_SHADERPIPELINE", .when(configuration: .release)),
    .define("HAVE_SLANG", .when(configuration: .release)),
    .define("HAVE_SPIRV_CROSS", .when(configuration: .release)),
    .define("HAVE_STB_FONT", .when(configuration: .release)),
    .define("HAVE_STB_VORBIS", .when(configuration: .release)),
    .define("HAVE_THREADS", .when(configuration: .release)),
    .define("HAVE_TRANSLATE", .when(configuration: .release)),
    .define("HAVE_UPDATE_ASSETS", .when(configuration: .release)),
    .define("HAVE_UPDATE_CORE_INFO", .when(configuration: .release)),
    .define("HAVE_VIDEO_LAYOUT", .when(configuration: .release)),
    .define("HAVE_VULKAN", .when(configuration: .release)),
    .define("HAVE_XMB", .when(configuration: .release)),
    .define("HAVE_ZLIB", .when(configuration: .release)),
    .define("INLINE", to: "inline", .when(configuration: .release)),
    .define("IOS", .when(configuration: .release)),
    .define("RARCH_INTERNAL", .when(configuration: .release)),
    .define("RARCH_MOBILE", .when(configuration: .release)),
    .define("RC_DISABLE_LUA", .when(configuration: .release)),
    .define("WANT_GLSLANG", .when(configuration: .release)),
    .define("_7ZIP_ST", .when(configuration: .release)),
    .define("_LZMA_UINT32_IS_ULONG", .when(configuration: .release)),
    .define("__LIBRETRO__", .when(configuration: .release)),
    .define("HAVE_OPENGLES3", .when(configuration: .release)),
    .define("HAVE_IOS_CUSTOMKEYBOARD", .when(configuration: .release)),
    .define("HAVE_IOS_TOUCHMOUSE", .when(configuration: .release)),
    .define("HAVE_IOS_SWIFT", .when(configuration: .release)),
    .define("TARGET_OS_IPHONE", to: "1", .when(configuration: .release)),
    .define("HAVE_VULKAN", to: "1", .when(configuration: .release)),
    .define("HAVE_SWRESAMPLE", to: "1", .when(configuration: .release)),
    .define("VULKAN_HDR_SWAPCHAIN", to: "1", .when(configuration: .release)),
    .define("HAVE_SHADERPIPELINE", .when(configuration: .release))
]

enum Sources {
    static var lhasa: [String] { [
        [
            // This files are #include'd
            //        "bit_stream_reader.c",
            //        "lh_new_decoder.c",
            //        "pma_common.c",
            //        "tree_decode.c",
            
            "crc16.c",
            "ext_header.c",
            "lha_arch_unix.c",
            "lha_arch_win32.c",
            "lha_decoder.c",
            "lha_endian.c",
            "lha_file_header.c",
            "lha_input_stream.c",
            "lha_basic_reader.c",
            "lha_reader.c",
            "macbinary.c",
            "null_decoder.c",
            "lh1_decoder.c",
            "lh5_decoder.c",
            "lh6_decoder.c",
            "lh7_decoder.c",
            "lhx_decoder.c",
            "lk7_decoder.c",
            "lz5_decoder.c",
            "lzs_decoder.c",
            "pm1_decoder.c",
            "pm2_decoder.c"
        ].map { "lib/\($0)" },
        [
            "extract.c",
            "filter.c",
            "list.c",
            "safe.c"
        ].map { "src/\($0)" }
    ].flatMap{ $0 }
    }
}