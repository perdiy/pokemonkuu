//
//  Model.swift
//  pokemonkuu
//
//  Created by Perdi Yansyah on 12/07/23.
//

import Foundation
struct PokemonListResponse: Decodable {
    let count: Int
    let next: URL?
    let previous: URL?
    let results: [Pokemon]
}

struct Pokemon: Decodable {
    let name: String
    let url: URL
    
}


// Detail Pokemon
struct DetailPokemon: Decodable {
    let abilities: [Ability]
    let id: Int
    let species: Species
    let height: Int
    let weight: Int
    let stats: [Stat]
    let moves: [Move]
    let types: [TypeElement]
}


struct Stat: Codable {
    let base_stat: Int
    let effort: Int
    let stat: Species
}

struct Move: Codable {
    let move: Species
}

struct Ability: Codable {
    let ability: Species
}

struct Species: Codable{
    let name: String
    let url: String
}
struct TypeElement: Decodable {
    let type: Species
}
