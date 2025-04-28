//
//  CharactersListViewModel.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 24/4/25.
//

import Foundation
import RickMortyModels
import RickMortyDomain

@MainActor
final class CharactersListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var characters: [CharacterModel] = []
    @Published var isLoading = false
    @Published var searchQuery = ""
    @Published var errorMessage: String?
    @Published var hasMorePages = true
    
    // MARK: - Private Properties
    private let characterUseCase: CharacterUseCaseProtocol
    private var currentPage = 1
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(characterUseCase: CharacterUseCaseProtocol) {
        self.characterUseCase = characterUseCase
    }
    
    // MARK: - Public Methods
    func fetchCharacters(reset: Bool = false) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        if reset {
            currentPage = 1
            hasMorePages = true
            characters = []
        }
        
        do {
            let fetchedCharacters = try await characterUseCase.getCharacters(
                page: currentPage,
                filter: searchQuery.isEmpty ? nil : searchQuery
            )
            handleNewCharacters(fetchedCharacters, reset: reset)
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
            let fetchedCharacters = try await characterUseCase.getCharacters(
                page: nextPage,
                filter: searchQuery.isEmpty ? nil : searchQuery
            )
            handleNewCharacters(fetchedCharacters, reset: false)
            currentPage = nextPage
        } catch {
            handleError(error)
        }
    }
    
    func shouldLoadMoreData(currentItem: CharacterModel) -> Bool {
        guard !isLoading, hasMorePages else { return false }
        
        if let currentIndex = characters.firstIndex(where: { $0.id == currentItem.id }) {
            let prefetchThreshold = 5
            let thresholdIndex = characters.index(characters.endIndex, offsetBy: -prefetchThreshold)
            return currentIndex >= thresholdIndex
        }
        
        return false
    }
    
    @MainActor
    func handleSearchChange(newQuery: String) async {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos debounce
            guard !Task.isCancelled else { return }

            if newQuery.isEmpty {
                // Si no estamos ya mostrando la lista general, recargar
                if hasMorePages || !characters.isEmpty {
                    await fetchCharacters(reset: true)
                }
                return
            }

            // Buscar por el nuevo término
            await fetchCharacters(reset: true)
        }
    }
    
    // MARK: - Private Methods
    private func handleNewCharacters(_ newCharacters: PaginatedCharacters, reset: Bool) {
        if reset {
            characters = newCharacters.characters
        } else {
            characters.append(contentsOf: newCharacters.characters)
        }
        hasMorePages = newCharacters.hasNextPage
        if newCharacters.characters.isEmpty {
            hasMorePages = false
        }
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        if currentPage == 1 {
            characters = []
        }
    }
}
