// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Caelum",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "Caelum", targets: ["Caelum"])
    ],
    targets: [
        .target(
            name: "Caelum",
            path: "Source",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("Core"),
                .headerSearchPath("REST"),
                .headerSearchPath("Gateway"),
                .headerSearchPath("Models"),
                .headerSearchPath("Client"),
            ]
        )
    ]
)
