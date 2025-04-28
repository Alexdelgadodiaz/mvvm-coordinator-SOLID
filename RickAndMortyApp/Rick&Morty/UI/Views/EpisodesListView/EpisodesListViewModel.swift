//
//  EpisodesListViewModel.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 24/4/25.
//

import SwiftUI
import RickMortyModels
import RickMortyDomain

@MainActor
final class EpisodesListViewModel: ObservableObject {
    @Published var episodes: [EpisodeModel] = []
    @Published var characters: [CharacterModel] = []
    @Published var isLoading = false
    @Published var isLoadingCharacters = false
    @Published var searchQuery = ""
    @Published var errorMessage: String?
    @Published var hasMorePages = true

    private let episodeUseCase: EpisodeUseCaseProtocol
    private var currentPage = 1
    private var searchTask: Task<Void, Never>?

    init(episodeUseCase: EpisodeUseCaseProtocol) {
        self.episodeUseCase = episodeUseCase
    }

    // MARK: - Public Methods

    func fetchEpisodes(reset: Bool = false) async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        if reset {
            currentPage = 1
            hasMorePages = true
        }

        do {
            let fetchedEpisodes = try await episodeUseCase.getEpisodes(
                page: currentPage,
                filter: searchQuery.isEmpty ? nil : searchQuery
            )
            handleNewEpisodes(fetchedEpisodes, reset: reset)
        } catch {
            handleError(error)
        }

        isLoading = false
    }

    func fetchNextPage() async {
        guard !isLoading, hasMorePages else { return }

        let nextPage = currentPage + 1
        
        isLoading = true
        defer { isLoading = false }

        do {
            let fetchedEpisodes = try await episodeUseCase.getEpisodes(
                page: nextPage,
                filter: searchQuery.isEmpty ? nil : searchQuery
            )
            handleNewEpisodes(fetchedEpisodes, reset: false)
            currentPage = nextPage
        } catch {
            handleError(error)
        }
    }

    func shouldLoadMoreData(currentItem: EpisodeModel) -> Bool {
        guard !isLoading, hasMorePages else { return false }
        
        if let currentIndex = episodes.firstIndex(where: { $0.id == currentItem.id }) {
            let prefetchThreshold = 5
            let thresholdIndex = episodes.index(episodes.endIndex, offsetBy: -prefetchThreshold)
            return currentIndex >= thresholdIndex
        }
        
        return false
    }


    // MARK: - Private Helpers

    private func handleNewEpisodes(_ newEpisodes: PaginatedEpisodes, reset: Bool) {
        if reset {
            episodes = newEpisodes.episodes
        } else {
            episodes.append(contentsOf: newEpisodes.episodes)
        }
        hasMorePages = newEpisodes.hasNextPage
    }

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        if currentPage == 1 {
            episodes = []
        }
    }

    @MainActor
    func handleSearchChange(newQuery: String) async {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos debounce
            guard !Task.isCancelled else { return }

            if newQuery.isEmpty {
                if hasMorePages || !episodes.isEmpty {
                    await fetchEpisodes(reset: true)
                }
                return
            }

            await fetchEpisodes(reset: true)
        }
    }
}
