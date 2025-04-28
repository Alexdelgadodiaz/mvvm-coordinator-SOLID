//
//  CharacterDetailViewModel.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 24/4/25.
//
import SwiftUI
import RickMortyModels
import RickMortyDomain

@MainActor
final class CharacterDetailViewModel: ObservableObject {
    @Published private(set) var character: CharacterModel
    @Published private(set) var episodes: [EpisodeModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    private let characterUseCase: CharacterUseCaseProtocol

    init(character: CharacterModel, characterUseCase: CharacterUseCaseProtocol) {
        self.character = character
        self.characterUseCase = characterUseCase
    }

    func fetchEpisodes() async {
        episodes = []
        isLoading = true
        errorMessage = nil

        do {
            let fetchedEpisodes = try await characterUseCase.getEpisodes(from: character.episode)
            episodes.append(contentsOf: fetchedEpisodes)
            episodes.sort {
                guard let id0 = Int($0.id), let id1 = Int($1.id) else {
                    return false
                }
                return id0 < id1
            }
            if episodes.isEmpty {
                errorMessage = NSLocalizedString("no_episodes_for_character", comment: "")
            }
        } catch {
            errorMessage = String(format: NSLocalizedString("error_loading_episodes", comment: ""), error.localizedDescription)
            episodes = []
        }

        isLoading = false
    }
}
