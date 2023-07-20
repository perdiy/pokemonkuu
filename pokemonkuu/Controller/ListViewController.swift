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
    private var viewModel = ListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.fetchFavoritePokemons()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfFavoritePokemons()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "list", for: indexPath)
        let favoritePokemon = viewModel.favoritePokemon(at: indexPath.row)
        
        cell.textLabel?.text = favoritePokemon.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPokemon = viewModel.favoritePokemon(at: indexPath.row)
        displayPokemonAlert(pokemon: selectedPokemon)
    }
    // alert detail klik pokemon list andalan
    func displayPokemonAlert(pokemon: FavoritePokemon) {
        let alert = UIAlertController(title: "Pokémon andalan", message: nil, preferredStyle: .alert)
        
        let imageView = UIImageView(frame: CGRect(x: 10, y: 70, width: 65, height: 65))
        imageView.contentMode = .scaleAspectFit
        
        // Check if the image URL exists
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
    
    // alert edit nama pokemon
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
            
            self.viewModel.updatePokemonName(at: indexPath.row, newName: newName)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        })
        
        alert.addAction(UIAlertAction(title: "tidak", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // delet uodate action tableview
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
    
    // alert delet yes or not
    func deleteFavoritePokemon(at indexPath: IndexPath) {
        // Show alert confirmation before deleting the favorite Pokemon
        let alert = UIAlertController(title: "Konfirmasi", message: "Apakah Anda yakin ingin menghapus Pokemon favorit ini?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ya", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            self.viewModel.deleteFavoritePokemon(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        })
        
        alert.addAction(UIAlertAction(title: "Tidak", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
