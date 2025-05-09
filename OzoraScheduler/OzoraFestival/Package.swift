// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "OzoraFestival",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "OzoraFestival", targets: ["OzoraFestival"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "OzoraFestival",
            dependencies: [],
            path: ".",
            sources: ["main.swift"],
            exclude: [
                "Info.plist", 
                "Views", 
                "Models", 
                "Services", 
                "Theme", 
                "AppDelegate.swift",
                "SceneDelegate.swift",
                "ContentView.swift",
                "OzoraApp.swift"
            ]
        )
    ]
)