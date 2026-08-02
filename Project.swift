//
//  Project.swift
//  ParkingMate
//
//  Created by 고재경 on 7/27/26.
//

import ProjectDescription

let appInfoPList: [String: Plist.Value] = [
    "CFBundleDisplayName": "주차도우미",
    "CFBundleShortVersionString": "$(MARKETING_VERSION)",
    "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
    "UILaunchScreen": [:],
    "UIApplicationSceneManifest": [
        "UIApplicationSupportsMultipleScenes": false
    ],
    "UISupportedInterfaceOrientations": ["UIInterfaceOrientationPortrait"],
    "UISupportedInterfaceOrientations~ipad": [
        "UIInterfaceOrientationPortrait",
        "UIInterfaceOrientationPortraitUpsideDown",
        "UIInterfaceOrientationLandscapeLeft",
        "UIInterfaceOrientationLandscapeRight"
    ],
    "NSLocationWhenInUseUsageDescription": "주차한 위치를 자동으로 저장하기 위해 위치 권한이 필요합니다.",
    "NSLocationAlwaysAndWhenInUseUsageDescription": "백그라운드에서도 주차 위치를 정확하게 기록하기 위해 항상 위치 권한이 필요합니다.",
    "NSCameraUsageDescription": "주차 위치를 사진으로 기록하기 위해 카메라 권한이 필요합니다.",
    "NSMicrophoneUsageDescription": "주차 위치를 음성으로 입력하기 위해 마이크 권한이 필요합니다.",
    "NSSpeechRecognitionUsageDescription": "음성을 텍스트로 변환하여 주차 위치를 기록하기 위해 음성 인식 권한이 필요합니다."
]

let project = Project(
    name: "ParkingMate",
    options: .options(
        defaultKnownRegions: ["en", "ko"],
        developmentRegion: "en",
        disableSynthesizedResourceAccessors: true
    ),
    settings: .settings(
        base: [
            "SWIFT_VERSION": "5.0",
            "MARKETING_VERSION": "1.0.2",
            "CURRENT_PROJECT_VERSION": "2",
            "SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY": "YES"
        ].automaticCodeSigning(devTeam: "LPHNDVUAA8")
    ),
    targets: [
        .target(
            name: "Core",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.jaekyeongko.ParkingMate.Core",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            buildableFolders: ["Projects/Core/Sources"]
        ),
        .target(
            name: "DesignSystem",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.jaekyeongko.ParkingMate.DesignSystem",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            buildableFolders: [
                "Projects/DesignSystem/Sources",
                "Projects/DesignSystem/Resources"
            ],
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "NO"
                ]
            )
        ),
        .target(
            name: "Services",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.jaekyeongko.ParkingMate.Services",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            buildableFolders: ["Projects/Services/Sources"],
            dependencies: [
                .target(name: "Core"),
                .external(name: "ComposableArchitecture")
            ]
        ),
        .target(
            name: "FeatureMap",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.jaekyeongko.ParkingMate.FeatureMap",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            buildableFolders: ["Projects/FeatureMap/Sources"],
            dependencies: [
                .target(name: "Core"),
                .target(name: "DesignSystem"),
                .target(name: "Services"),
                .external(name: "ComposableArchitecture")
            ]
        ),
        .target(
            name: "FeatureForm",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.jaekyeongko.ParkingMate.FeatureForm",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            buildableFolders: ["Projects/FeatureForm/Sources"],
            dependencies: [
                .target(name: "Core"),
                .target(name: "DesignSystem"),
                .target(name: "Services"),
                .external(name: "ComposableArchitecture")
            ]
        ),
        .target(
            name: "AppFeature",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.jaekyeongko.ParkingMate.AppFeature",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            buildableFolders: ["Projects/AppFeature/Sources"],
            dependencies: [
                .target(name: "FeatureHome"),
                .target(name: "FeatureForm"),
                .target(name: "FeatureMap"),
                .external(name: "ComposableArchitecture")
            ]
        ),
        .target(
            name: "FeatureHome",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.jaekyeongko.ParkingMate.FeatureHome",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            buildableFolders: ["Projects/FeatureHome/Sources"],
            dependencies: [
                .target(name: "Core"),
                .target(name: "DesignSystem"),
                .target(name: "Services"),
                .external(name: "ComposableArchitecture")
            ]
        ),
        .target(
            name: "ParkingMate",
            destinations: .iOS,
            product: .app,
            bundleId: "com.jaekyeongko.ParkingMate",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: appInfoPList),
            buildableFolders: [
                "Projects/App/Sources",
                "Projects/App/Resources"
            ],
            dependencies: [
                .target(name: "AppFeature"),
                .external(name: "ComposableArchitecture")
            ],
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
                    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
                    "SWIFT_EMIT_LOC_STRINGS": "YES"
                ]
            )
        ),
        .target(
            name: "FeatureHomeTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.jaekyeongko.ParkingMate.FeatureHomeTests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            buildableFolders: ["Projects/FeatureHome/Tests"],
            dependencies: [
                .target(name: "FeatureHome"),
                .target(name: "Core"),
                .target(name: "Services"),
                .external(name: "ComposableArchitecture")
            ]
        ),
        .target(
            name: "FeatureFormTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.jaekyeongko.ParkingMate.FeatureHomeTests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            buildableFolders: ["Projects/FeatureForm/Tests"],
            dependencies: [
                .target(name: "FeatureForm"),
                .target(name: "Services"),
                .external(name: "ComposableArchitecture")
            ]
        ),
        .target(
            name: "FeatureMapTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.jaekyeongko.ParkingMate.FeatureHomeTests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            buildableFolders: ["Projects/FeatureMap/Tests"],
            dependencies: [
                .target(name: "FeatureMap"),
                .external(name: "ComposableArchitecture")
            ]
        ),
        .target(
            name: "AppFeatureTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.jaekyeongko.ParkingMate.FeatureHomeTests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            buildableFolders: ["Projects/AppFeature/Tests"],
            dependencies: [
                .target(name: "AppFeature"),
                .target(name: "FeatureHome"),
                .target(name: "FeatureForm"),
                .target(name: "FeatureMap"),
                .external(name: "ComposableArchitecture")
            ]
        )
    ],
    schemes: [
        .scheme(
            name: "ParkingMate",
            shared: true,
            buildAction: .buildAction(targets: ["ParkingMate"]),
            testAction: .targets([
                "FeatureHomeTests",
                "FeatureFormTests",
                "FeatureMapTests",
                "AppFeatureTests"
            ]),
            runAction: .runAction(executable: .target("ParkingMate"))
        )
    ]
)
