//
//  DependencyContainerProtocol.swift
//  Rick&Morty
//
//  Created by AlexDelgado on 9/5/25.
//

import RickMortyAPI
import RickMortyDomain

protocol DependencyContainerProtocol {  
    var apiManager: CharacterAPIManagerProtocol { get }  
    var cache: DomaCacheProtocol { get }  
    var characterRepository: CharacterRepositoryProtocol { get }
    var episodeRepository: EpisodeRepositoryProtocol { get }
    var characterUseCase: CharacterUseCaseProtocol { get }  
    var episodeUseCase: EpisodeUseCaseProtocol { get }  
}  
  
class DependencyContainer: DependencyContainerProtocol {  
    let apiManager: CharacterAPIManagerProtocol  
    let cache: DomaCacheProtocol  
      
    lazy var characterRepository: CharacterRepositoryProtocol = {  
        DefaultCharacterRepository(apiManager: apiManager, domaCache: cache)  
    }()  
      
    lazy var episodeRepository: EpisodeRepositoryProtocol = {  
        DefaultEpisodeRepository(apiManager: apiManager, domaCache: cache)  
    }()
    

      
    lazy var characterUseCase: CharacterUseCaseProtocol = {  
        DefaultCharacterUseCase(repository: characterRepository)  
    }()  
      
    lazy var episodeUseCase: EpisodeUseCaseProtocol = {  
        DefaultEpisodeUseCase(repository: episodeRepository)  
    }()
    
    
    
      
    init(apiManager: CharacterAPIManagerProtocol = DefaultCharacterAPIManager(),  
         cache: DomaCacheProtocol = DomaCache()) {  
        self.apiManager = apiManager  
        self.cache = cache  
    }  
}
