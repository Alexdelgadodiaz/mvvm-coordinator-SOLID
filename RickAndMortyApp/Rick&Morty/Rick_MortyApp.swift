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
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(coordinator)
                .environment(NetworkMonitor.shared)
        }
    }
}

struct RootView: View {
    @Environment(NetworkMonitor.self) private var networkMonitor
    @EnvironmentObject private var coordinator: AppCoordinator
    
    var body: some View {
        if networkMonitor.isConnected {
            MainTabView()
                .environmentObject(coordinator)
        } else {
            NoConnectionView()
        }
    }
}
