//
//  EpisodesResponse.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 24/4/25.
//

import Foundation

package struct EpisodesResponse: Decodable {
    package let info: InfoAPIModel
    package let results: [EpisodeAPIModel]
}

public struct EpisodeAPIModel: Decodable, Sendable {
    public let id: Int
    public let name: String
    public let air_date: String
    public let episode: String
    public let characters: [String]
    
    public init(id: Int, name: String, air_date: String, episode: String, characters: [String]) {
        self.id = id
        self.name = name
        self.air_date = air_date
        self.episode = episode
        self.characters = characters
    }
    
}

package struct InfoAPIModel: Decodable {
    package let next: String?
}
