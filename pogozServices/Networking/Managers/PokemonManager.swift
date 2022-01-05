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
}
