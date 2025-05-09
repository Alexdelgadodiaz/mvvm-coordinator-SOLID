//
//  AppCoordinator.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 24/4/25.
//

import SwiftUI
import RickMortyAPI
import RickMortyDomain
import RickMortyModels

struct MainTabView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            CharactersTab()
                .tabItem {
                    Label(NSLocalizedString("characters", comment: "Characters list title"), systemImage: "person.3")
                }
                .tag(Tab.characters)

            EpisodesTab()
                .tabItem {
                    Label("episodes", systemImage: "tv")
                }
                .tag(Tab.episodes)
        }
    }
}

// MARK: - AppCoordinator

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var selectedTab: Tab = .characters
    @Published var charactersPath = NavigationPath()
    @Published var episodesPath = NavigationPath()

    @Published private(set) var charactersListViewModel: CharactersListViewModel
    @Published private(set) var episodesListViewModel: EpisodesListViewModel

    private let container: DependencyContainerProtocol
      
    init(container: DependencyContainerProtocol = DependencyContainer()) {
        
        self.container = container
          
        self.charactersListViewModel = CharactersListViewModel(
            characterUseCase: container.characterUseCase
        )
        self.episodesListViewModel = EpisodesListViewModel(
            episodeUseCase: container.episodeUseCase
        )
    }
    
    // Los ViewModel detail siguen como factories dinámicas
    func makeCharacterDetailViewModel(for character: CharacterModel) -> CharacterDetailViewModel {
        
        return CharacterDetailViewModel(
            character: character,
            characterUseCase: self.container.characterUseCase
        )
    }

    func makeEpisodeDetailViewModel(for episode: EpisodeModel) -> EpisodeDetailViewModel {

        return EpisodeDetailViewModel(
            episode: episode,
            episodeUseCase: self.container.episodeUseCase
        )
    }
}

enum Tab: Hashable {
    case characters
    case episodes
}

struct CharactersTab: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.charactersPath) {
            CharactersListView(viewModel: coordinator.charactersListViewModel)
                .navigationDestination(for: AppRouteCharacters.self) { route in
                    switch route {
                    case .characterDetail(let character):
                        CharacterDetailView(viewModel: coordinator.makeCharacterDetailViewModel(for: character))
                    }
                }
        }
    }
}

struct EpisodesTab: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.episodesPath) {
            EpisodesListView(viewModel: coordinator.episodesListViewModel)
                .navigationDestination(for: AppRouteEpisodes.self) { route in
                    switch route {
                    case .episodeDetail(let episode):
                        EpisodeDetailView(viewModel: coordinator.makeEpisodeDetailViewModel(for: episode))
                    }
                }
        }
    }
}

enum AppRouteCharacters: Hashable, Identifiable {
    case characterDetail(CharacterModel)

    var id: String {
        switch self {
        case .characterDetail(let character):
            return "character_\(character.id)"
        }
    }
}

// MARK: - AppRouteEpisodes

enum AppRouteEpisodes: Hashable, Identifiable {
    case episodeDetail(EpisodeModel)

    var id: String {
        switch self {
        case .episodeDetail(let episode):
            return "episode_\(episode.id)"
        }
    }
}

extension AppCoordinator {
    func showCharacterDetail(_ character: CharacterModel) {
        charactersPath.append(AppRouteCharacters.characterDetail(character))
    }

    func showEpisodeDetail(_ episode: EpisodeModel) {
        episodesPath.append(AppRouteEpisodes.episodeDetail(episode))
    }
    func showCharacterDetailFromAnywhere(_ character: CharacterModel) {
        selectedTab = .characters
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.showCharacterDetail(character)
        }
    }
    func showEpisodeDetailFromAnywhere(_ episode: EpisodeModel) {
        selectedTab = .episodes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.showEpisodeDetail(episode)
        }
    }
}
