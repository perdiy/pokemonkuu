//
//  PokemonManager.swift
//  pokemonkuu
//
//  Created by Perdi Yansyah on 13/07/23.
//
import Foundation
//
//class PokemonManager {
//
//
//    //Function for custom URL with completion
//    func getDataApi(abilitiesLink: String, completion: @escaping ([Ability]) -> Void) {
//        let url = URL(string: abilitiesLink)
//        URLSession.shared.dataTask(with: url!) { (data, response, error) in if let error = error {
//                print("gagal: ", error.localizedDescription)
//                return
//            }
//            guard let data = data,
//                  let response = response as? HTTPURLResponse,
//                  200..<300 ~= response.statusCode,
//                  error == nil
//
//            else { return }
//            do {
//                guard let pokemon = try? JSONDecoder().decode(DetailPokemon.self, from: data) else { return }
//
//                for pokey in pokemon.abilities {
//                    let name = pokey.ability
//                    print("NamaDetail: \(name)")
//                }
//                completion(pokemon.abilities)
//            }
//        }.resume()
//
//    }
//}

class PokemonManager {
    
    func getDataApi(abilitiesLink: String, completion: @escaping (DetailPokemon) -> Void) {
        let url = URL(string: abilitiesLink)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                print("gagal: ", error.localizedDescription)
                return
            }
            
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  200..<300 ~= response.statusCode,
                  error == nil
            else {
                return
            }
            
            do {
                let detailPokemon = try JSONDecoder().decode(DetailPokemon.self, from: data)
                completion(detailPokemon)
            } catch {
                print("Error decoding response: \(error)")
            }
        }.resume()
    }
}
