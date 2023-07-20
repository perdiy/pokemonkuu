//
//  PokemonModel.swift
//  pokemonkuu
//
//  Created by Perdi Yansyah on 18/07/23.
//
import Foundation
import UIKit

class PokemonViewModel {
    private var data: [Pokemon] = []
    private var nextURL: URL?
    
    // fetch APIs pokemon
    func fetchData(completion: @escaping () -> Void) {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon") else {
            return
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data else {
                return
            }
            
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            do {
                let pokemonListResponse = try JSONDecoder().decode(PokemonListResponse.self, from: data)
                self.data = pokemonListResponse.results
                self.nextURL = pokemonListResponse.next
                
                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                print("Error decoding response: \(error)")
            }
        }
        
        dataTask.resume()
    }
    
    // next url data pokemon
    func loadMorePokemon(completion: @escaping () -> Void) {
        guard let nextURL = nextURL else {
            return
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: nextURL) { [weak self] data, _, error in
            guard let self = self, let data = data else {
                return
            }
            
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            do {
                let pokemonListResponse = try JSONDecoder().decode(PokemonListResponse.self, from: data)
                self.data += pokemonListResponse.results
                self.nextURL = pokemonListResponse.next
                
                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                print("Error decoding response: \(error)")
            }
        }
        
        dataTask.resume()
    }
    
    // kembalikan jumlah poke
    func numberOfPokemon() -> Int {
        return data.count
    }
    
    // get data pokemon array index
    func pokemon(at index: Int) -> Pokemon {
        return data[index]
    }
    
    // image
    func loadImageForPokemon(at index: Int, completion: @escaping (UIImage?) -> Void) {
        let imageUrlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(index + 1).png"
        if let imageUrl = URL(string: imageUrlString) {
            let session = URLSession.shared
            let dataTask = session.dataTask(with: imageUrl) { data, response, error in
                if let error = error {
                    print("Error loading image: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                if let imageData = data, let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
            
            dataTask.resume()
        } else {
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
}
