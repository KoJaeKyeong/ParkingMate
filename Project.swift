//
//  Project.swift
//  ParkingMate
//
//  Created by 고재경 on 7/27/26.
//

import ProjectDescription

let appInfoPList: [String: Plist.Value] = [
    "CFBundleDisplayName": "주차도우미",
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
            "MARKETING_VERSION": "1.0.1",
            "CURRENT_PROJECT_VERSION": "1"
        ].automaticCodeSigning(devTeam: "LPHNDVUAA8")
    ),
    targets: [
        .target(
            name: "ParkingMate",
            destinations: .iOS,
            product: .app,
            bundleId: "com.jaekyeongko.ParkingMate",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: appInfoPList),
            sources: ["ParkingMate/ParkingMate/**/*.swift"],
            resources: [
                "ParkingMate/ParkingMate/Assets.xcassets",
                "ParkingMate/ParkingMate/*.xcstrings"
            ],
            dependencies: [
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
            name: "ParkingMateTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.jaekyeongko.ParkingMateTests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["ParkingMate/ParkingMateTests/**/*.swift"],
            dependencies: [
                .target(name: "ParkingMate"),
                .external(name: "ComposableArchitecture")
            ]
        )
    ]
)
