//
//  RickMortyApp.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 24/4/25.
//

import SwiftUI

@main
struct RickMortyApp: App {
    @StateObject private var coordinator = AppCoordinator()

    init() {
        print("✅ RickMortyApp initialized")

    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(coordinator)
        }
    }
}
