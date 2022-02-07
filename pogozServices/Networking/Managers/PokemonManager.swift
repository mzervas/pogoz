//
//  PokemonManager.swift
//  pogozServices
//
//  Created by Merri Zervas on 12/20/21.
//

import Foundation
import RxAlamofire
import RxSwift
import RxCocoa
import Alamofire

public enum NetworkError: Error {
    case badURL
    case badResponse
    case unknown
}

public class PokemonManager {
    
    public var pokemon = BehaviorRelay<Pokedex?>(value: nil)
    public var shinyDetails = BehaviorRelay<ShinyDetails>(value: [:])

    private let bag = DisposeBag()
    
    public init() { }
    
    public func sansRxGetPokemonNames(completion: @escaping (Pokedex) -> Void) {
        guard let url = URL(string: "https://pogoapi.net/api/v1/pokemon_names.json") else {
            return
        }
        
        AF.request(url).responseDecodable(of: [String: PokemonName].self) { response in
            if let response = response.value {
                completion(response)
            }
        }
    }
    
    public func sansRxGetShinyDetails(competion: @escaping (ShinyDetails) -> Void) {
        guard let detailsURL = URL(string: "https://pogoapi.net/api/v1/shiny_pokemon.json") else {
            return
        }
        
        AF.request(detailsURL).responseDecodable(of: ShinyDetails.self) { response in
            if let shinyResponse = response.value {
                competion(shinyResponse)
            }
        }
    }
    
    public func sansRxPokemon(completion: @escaping (Result<ShinyDetails, NetworkError>) -> Void) {
        guard let url = URL(string: "https://pogoapi.net/api/v1/pokemon_names.json"), let detailsURL = URL(string: "https://pogoapi.net/api/v1/shiny_pokemon.json") else {
            completion(.failure(.badURL))
            return
        }
        
        let urls = [url, detailsURL]
        var pokemon2: Pokedex = [:]
        var shinyDetails2: ShinyDetails = [:]
        
        let dispatchGroup = DispatchGroup()
        
        urls.forEach { url in
            dispatchGroup.enter()
            URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: { data, response, error  in
                guard let data = data else {
                    dispatchGroup.leave()
                    completion(.failure(.badResponse))
                    return
                }

                if url == urls.first, let pokemon = try? JSONDecoder().decode([String: PokemonName].self, from: data) {
                    pokemon2 = pokemon
                    dispatchGroup.leave()

                } else if let shinyDetails = try? JSONDecoder().decode(ShinyDetails.self, from: data) {
                    shinyDetails2 = shinyDetails
                    dispatchGroup.leave()
                }
            }).resume()
        }
                        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else {
                completion(.failure(.unknown))
                return
            }
        
            let all = self.sansRxCombinePokemonShiny(pokemon: pokemon2, shinyDetails: shinyDetails2)
            completion(.success(all))
        }
    }

    public func getPokemonNames() {
        guard let url = URL(string: "https://pogoapi.net/api/v1/pokemon_names.json"), let detailsURL = URL(string: "https://pogoapi.net/api/v1/shiny_pokemon.json") else {
            return
        }
        
        _ = requestData(.get, url)
            .subscribe(onNext: { [weak self] (response, data) in
                guard let self = self else { return }
                
                let decoder = JSONDecoder()
                if let pokemon = try? decoder.decode([String: PokemonName].self, from: data) {
                    self.pokemon.accept(pokemon)
                }
            }, onError: { error in
                print("!!! \(error)")
            })
        
        _ = requestData(.get, detailsURL)
            .subscribe(onNext: { [weak self] (response, data) in
                guard let self = self else { return }
                
                let decoder = JSONDecoder()
                if let details = try? decoder.decode(ShinyDetails.self, from: data) {
                    self.combinePokemonShiny(shinyDetails: details)
                }
            }, onError: { error in
                print("!!! \(error)")
            })
        
    }
    
    func combinePokemonShiny(shinyDetails: ShinyDetails) {
        guard let pokemon = pokemon.value else { return }
        
        var newDict: [String: PokemonShinyDetails] = [:]
        for item in pokemon {
            
            if !shinyDetails.contains(where: { $0.key == item.key }) {
                guard let pokeIndex = pokemon[item.key], let id = pokeIndex.id, let name = pokeIndex.name else { break }
                newDict[item.key] = PokemonShinyDetails(id: id, name: name, foundEgg: false, foundEvolution: false,
                                                 foundPhotoBomb: false, foundRaid: false, foundResearch: false, foundWild: false)
            } else {
                guard let pokeIndex = shinyDetails[item.key] else { break }
                newDict[item.key] = pokeIndex
            }
        
        }
        
        self.shinyDetails.accept(newDict)
    }
    
    func sansRxCombinePokemonShiny(pokemon: Pokedex, shinyDetails: ShinyDetails) -> ShinyDetails {
        var newDict: [String: PokemonShinyDetails] = [:]
        for item in pokemon {
            if !shinyDetails.contains(where: { $0.key == item.key }) {
                guard let pokeIndex = pokemon[item.key], let id = pokeIndex.id, let name = pokeIndex.name else { break }
                newDict[item.key] = PokemonShinyDetails(id: id, name: name, foundEgg: false, foundEvolution: false,
                                                 foundPhotoBomb: false, foundRaid: false, foundResearch: false, foundWild: false)
            } else {
                guard let pokeIndex = shinyDetails[item.key] else { break }
                newDict[item.key] = pokeIndex
            }
        }
        
        return newDict
    }
}
