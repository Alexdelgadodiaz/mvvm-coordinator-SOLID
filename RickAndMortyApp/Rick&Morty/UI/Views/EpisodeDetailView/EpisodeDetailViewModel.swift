//
//  EpisodeDetailViewModel.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 25/4/25.
//


import SwiftUI
import RickMortyModels
import RickMortyDomain

@MainActor
class EpisodeDetailViewModel: ObservableObject {
    @Published private(set) var episode: EpisodeModel
    @Published private(set) var characters: [CharacterModel] = []
    @Published private(set) var isLoadingCharacters = false
    @Published private(set) var errorMessage: String?
    
    private let episodeUseCase: EpisodeUseCaseProtocol
    
    init(
        episode: EpisodeModel,
        episodeUseCase: EpisodeUseCaseProtocol
    ) {
        self.episode = episode
        self.episodeUseCase = episodeUseCase
    }
    
    func fetchCharacters(for urls: [String]) async {
        characters = []

        isLoadingCharacters = true
        errorMessage = nil

        do {
            let characters2 = try await episodeUseCase.getCharacters(from: urls)
            characters.append(contentsOf: characters2)
            characters.sort {
                guard let id0 = Int($0.id), let id1 = Int($1.id) else {
                    return false
                }
                return id0 < id1
            }
            if characters.isEmpty {
                errorMessage = "No se encontraron personajes"
            }
        } catch {
            errorMessage = "Error cargando personajes: \(error.localizedDescription)"
            characters = []
        }

        isLoadingCharacters = false
    }
}
