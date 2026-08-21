// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Spendly",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Spendly",
            targets: ["Spendly"]
        )
    ],
    targets: [
        .target(
            name: "Spendly",
            dependencies: [],
            path: "Spendly",
            swiftSettings: [
                .unsafeFlags(["-suppress-warnings"])
            ]
        ),
        .testTarget(
            name: "SpendlyTests",
            dependencies: ["Spendly"],
            path: "Tests"
        )
    ]
)
