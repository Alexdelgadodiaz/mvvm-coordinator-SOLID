//
//  EpisodeModel.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 27/4/25.
//

import Foundation

public struct EpisodeModel: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let name: String
    public let air_date: String
    public let episode: String
    public let characters: [String]

    package init(apiModel: EpisodeAPIModel) {
        self.id = String(apiModel.id)
        self.name = apiModel.name
        self.air_date = apiModel.air_date
        self.episode = apiModel.episode
        self.characters = apiModel.characters
    }
    
    public init(from apiModel: EpisodeAPIModel) {
        self.id = String(apiModel.id)
        self.name = apiModel.name
        self.air_date = apiModel.air_date
        self.episode = apiModel.episode
        self.characters = apiModel.characters
    }
}

public struct PaginatedEpisodes: Codable, Sendable {
    public let episodes: [EpisodeModel]
    public let hasNextPage: Bool

    public init(episodes: [EpisodeModel], hasNextPage: Bool) {
        self.episodes = episodes
        self.hasNextPage = hasNextPage
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.episodes = try container.decode([EpisodeModel].self, forKey: .episodes)
        self.hasNextPage = try container.decode(Bool.self, forKey: .hasNextPage)
    }

    private enum CodingKeys: String, CodingKey {
        case episodes
        case hasNextPage
    }
}
