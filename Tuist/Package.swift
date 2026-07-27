// swift-tools-version: 5.9
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings

let packageSettings = PackageSettings(
    baseProductType: .staticFramework
)
#endif

let package = Package(
    name: "ParkingMateDependencies",
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture.git",
            exact: "1.20.2"
        )
    ]
)
