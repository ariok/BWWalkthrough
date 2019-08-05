// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "BWWalkthrough",
    platforms: [.iOS(.v10)],
    products: [
        .library(name: "BWWalkthrough", targets: ["BWWalkthrough"])
    ],
    targets: [
        .target(
            name: "BWWalkthrough",
            path: "BWWalkthrough"
        )
    ]
)
