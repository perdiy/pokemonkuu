//
//  ListViewController.swift
//  pokemonkuu
//
//  Created by Perdi Yansyah on 17/07/23.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Data sumber Pokemon dari Core Data Array
    var favoritePokemons: [FavoritePokemon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // Ambil data dari Core Data setiap kali tampilan mucul
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchFavoritePokemons()
    }
    
    // Fungsi untuk mengambil data FavoritePokemon dari Core Data
    func fetchFavoritePokemons() {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        
        let fetchRequest: NSFetchRequest<FavoritePokemon> = FavoritePokemon.fetchRequest()
        
        do {
            // Ambil data dari Core Data dan simpan dalam array favoritePokemons
            favoritePokemons = try context.fetch(fetchRequest)
            
            tableView.reloadData()
            
        } catch {
            print("Failed to fetch favorite Pokemon:", error)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritePokemons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath)
        let favoritePokemon = favoritePokemons[indexPath.row]
        
        // Konfigurasi sel sesuai dengan data FavoritePokemon
        cell.textLabel?.text = favoritePokemon.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPokemon = favoritePokemons[indexPath.row]
        displayPokemonAlert(pokemon: selectedPokemon)
    }
    
    // tampilan data alert
    func displayPokemonAlert(pokemon: FavoritePokemon) {
        let alert = UIAlertController(title: "Pokémon andalan", message: nil, preferredStyle: .alert)
        
        let imageView = UIImageView(frame: CGRect(x: 10, y: 70, width: 65, height: 65))
        imageView.contentMode = .scaleAspectFit
        
        // cek img url apakah ada
        if let imageUrlString = pokemon.imageUrl, let imageUrl = URL(string: imageUrlString) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageUrl),
                   let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                }
            }
        }
        
        alert.view.addSubview(imageView)
        alert.addAction(UIAlertAction(title: "Mantap!", style: .default, handler: nil))
        
        var message = "\n"
        message += "ID: \(pokemon.id)\n"
        message += "Name: \(pokemon.name ?? "N/A")\n"
        message += "Species: \(pokemon.species ?? "N/A")\n"
        message += "Height: \(pokemon.height)\n"
        message += "Weight: \(pokemon.weight)\n"
        message += "Type: \(pokemon.type ?? "N/A")\n"
        
        alert.message = message
        
        present(alert, animated: true, completion: nil)
    }
    
    // Function handle UPDATE action name
    func updatePokemonName(at indexPath: IndexPath, newName: String) {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        
        let favoritePokemon = favoritePokemons[indexPath.row]
        favoritePokemon.name = newName
        
        do {
            try context.save()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            // Display a confirmation alert for the name update
            let alert = UIAlertController(title: "Success", message: "The Pokemon name has been updated.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
        } catch {
            print("Failed to update Pokemon name:", error)
        }
    }
    
    // Func alert handle the update action for the Pokemon
    func alertUpdateFavoritePokemon(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Ubah Nama Pokemon", message: "Nama baru pokemon:", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Nama Baru Pokemon"
        }
        
        alert.addAction(UIAlertAction(title: "ubah", style: .default) { [weak self, weak alert] _ in
            guard let self = self,
                  let textField = alert?.textFields?.first,
                  let newName = textField.text else {
                return
            }
            
            self.updatePokemonName(at: indexPath, newName: newName)
        })
        
        alert.addAction(UIAlertAction(title: "tidak", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // action delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            self.deleteFavoritePokemon(at: indexPath)
            
            completionHandler(true)
        }
        
        if let trashIcon = UIImage(systemName: "trash") {
            deleteAction.image = trashIcon
        }
        
        // Update action
        let updateAction = UIContextualAction(style: .normal, title: "") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            self.alertUpdateFavoritePokemon(at: indexPath)
            
            completionHandler(true)
        }
        
        if let updateIcon = UIImage(systemName: "pencil") {
            updateAction.image = updateIcon
        }
        
        updateAction.backgroundColor = .systemYellow
        
        return UISwipeActionsConfiguration(actions: [deleteAction, updateAction])
    }
    
    // Fungsi untuk DELETE FavoritePokemon dari Core Data dan memperbarui tabel
    func deleteFavoritePokemon(at indexPath: IndexPath) {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        
        let favoritePokemon = favoritePokemons[indexPath.row]
        context.delete(favoritePokemon)
        
        do {
            try context.save()
            
            favoritePokemons.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        } catch {
            print("Failed to delete favorite Pokemon:", error)
        }
    }
}
