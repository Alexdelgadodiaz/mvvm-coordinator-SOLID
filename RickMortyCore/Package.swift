// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RickMortyCore",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "RickMortyCore",
            targets: ["RickMortyAPI", "RickMortyDomain", "RickMortyModels", "RickMortyShared"])

        
    ],
    targets: [
        
        // Capa de API/Network
        .target(
            name: "RickMortyAPI",
            dependencies: [
                "RickMortyModels",
                "RickMortyShared"
            ],
            path: "Sources/Data",
            sources: ["API", "Cache"]
        ),
        
        // Capa de Domain
        .target(
            name: "RickMortyDomain",
            dependencies: [
                "RickMortyModels",
                "RickMortyShared",
                "RickMortyAPI"
            ],
            path: "Sources/Domain",
            sources: ["Repository", "UseCase"]
        ),
        
        // Modelos
        .target(
            name: "RickMortyModels",
            dependencies: [
                "RickMortyShared"
            ],
            path: "Sources/Model",
            sources: ["Models"]

        ),
        
        // Utilidades compartidas
        .target(
            name: "RickMortyShared",
            path: "Sources/Shared",
            sources: ["Error", "Extensions", "Logger", "localized"]
        )
    ]
)
