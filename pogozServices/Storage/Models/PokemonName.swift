//
//  Pokemon.swift
//  pogozServices
//
//  Created by Merri Zervas on 12/20/21.
//

import Foundation

public typealias Pokedex = [String: PokemonName]

public struct PokemonName: Codable {
    
    let id : Int?
    public let name : String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
    }

}

// MARK: PokemonShinyDetails

public struct PokemonShinyDetails: Codable {
    public let foundEgg, foundEvolution, foundPhotobomb, foundRaid: Bool
    public let foundResearch, foundWild: Bool
    public let id: Int
    public let name: String

    enum CodingKeys: String, CodingKey {
        case foundEgg = "found_egg"
        case foundEvolution = "found_evolution"
        case foundPhotobomb = "found_photobomb"
        case foundRaid = "found_raid"
        case foundResearch = "found_research"
        case foundWild = "found_wild"
        case id, name
    }
    
    init(id: Int, name: String, foundEgg: Bool, foundEvolution: Bool, foundPhotoBomb: Bool, foundRaid: Bool, foundResearch: Bool, foundWild: Bool) {
        self.foundResearch = foundResearch
        self.foundEgg = foundEgg
        self.foundPhotobomb = foundPhotoBomb
        self.foundEvolution = foundEvolution
        self.foundRaid = foundRaid
        self.foundWild = foundWild
        self.id = id
        self.name = name
    }
}

public typealias ShinyDetails = [String: PokemonShinyDetails]
