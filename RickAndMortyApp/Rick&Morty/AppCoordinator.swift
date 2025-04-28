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
                    Label("Characters", systemImage: "person.3")
                }
                .tag(Tab.characters)

            EpisodesTab()
                .tabItem {
                    Label("Episodes", systemImage: "tv")
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

    private let apiManager: CharacterAPIManagerProtocol
    private let domeCache: DomaCache

    init() {
        self.apiManager = DefaultCharacterAPIManager()
        self.domeCache = DomaCache()
        let characterRepository = DefaultCharacterRepository(apiManager: apiManager, domaCache: domeCache)
        let episodeRepository = DefaultEpisodeRepository(apiManager: apiManager, domaCache: domeCache)

        self.charactersListViewModel = CharactersListViewModel(
            characterUseCase: DefaultCharacterUseCase(repository: characterRepository)
        )
        self.episodesListViewModel = EpisodesListViewModel(
            episodeUseCase: DefaultEpisodeUseCase(repository: episodeRepository)
        )
    }

    // Los ViewModel detail siguen como factories dinámicas
    func makeCharacterDetailViewModel(for character: CharacterModel) -> CharacterDetailViewModel {
        let characterRepository = DefaultCharacterRepository(apiManager: apiManager, domaCache: domeCache)

        return CharacterDetailViewModel(
            character: character,
            characterUseCase: DefaultCharacterUseCase(repository: characterRepository)
        )
    }

    func makeEpisodeDetailViewModel(for episode: EpisodeModel) -> EpisodeDetailViewModel {
        let episodeRepository = DefaultEpisodeRepository(apiManager: apiManager, domaCache: domeCache)

        return EpisodeDetailViewModel(
            episode: episode,
            episodeUseCase: DefaultEpisodeUseCase(repository: episodeRepository)
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
