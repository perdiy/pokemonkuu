//
//  ListModel.swift
//  pokemonkuu
//
//  Created by Perdi Yansyah on 20/07/23.
//


import UIKit
import Foundation
import CoreData

class ListViewModel {
    private var favoritePokemons: [FavoritePokemon] = []
    
    func fetchFavoritePokemons() {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        
        let fetchRequest: NSFetchRequest<FavoritePokemon> = FavoritePokemon.fetchRequest()
        
        do {
            favoritePokemons = try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch favorite Pokemon:", error)
        }
    }
    
    func numberOfFavoritePokemons() -> Int {
        return favoritePokemons.count
    }
    
    func favoritePokemon(at index: Int) -> FavoritePokemon {
        return favoritePokemons[index]
    }
    
    func updatePokemonName(at index: Int, newName: String) {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        
        let favoritePokemon = favoritePokemons[index]
        favoritePokemon.name = newName
        
        do {
            try context.save()
        } catch {
            print("Failed to update Pokemon name:", error)
        }
    }
    
    func deleteFavoritePokemon(at index: Int) {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        
        let favoritePokemon = favoritePokemons[index]
        context.delete(favoritePokemon)
        
        do {
            try context.save()
            favoritePokemons.remove(at: index)
        } catch {
            print("Failed to delete favorite Pokemon:", error)
        }
    }
}
