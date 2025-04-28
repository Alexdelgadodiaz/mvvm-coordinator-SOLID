//
//  CharacterAPIManagerProtocol.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 24/4/25.
//
import RickMortyModels

public protocol CharacterAPIManagerProtocol {
    func fetchCharacters(page: Int, filter: String?) async throws -> PaginatedCharacters
    func fetchEpisodes(page: Int, filter: String?) async throws -> PaginatedEpisodes
    func fetchCharacters(for urls: [String]) async throws -> [CharacterModel]
    func fetchEpisodes(for urls: [String]) async throws -> [EpisodeModel]
}
