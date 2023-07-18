//
//  DetailViewController.swift
//  pokemonkuu
//
//  Created by Perdi Yansyah on 12/07/23.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    var pokemonName: String = ""
    var pokemonImgURL: URL?
    var pokemonUrl: String = ""
    var ability: [Ability] = []
    var detailPokemon: DetailPokemon?
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var specLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var speciesLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var moveProgres: UIProgressView!
    @IBOutlet weak var tastProgres: UIProgressView!
    @IBOutlet weak var typeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // memanggil data dari APIs
        PokemonManager().getDataApi(abilitiesLink: pokemonUrl) { detailPokemon in
            self.detailPokemon = detailPokemon
            
            DispatchQueue.main.async {
                let moveCount = self.detailPokemon?.moves.count ?? 0
                let progress = Float(moveCount) / 100.0
                self.moveProgres.progress = progress
                
                if let detailPokemon = self.detailPokemon,
                   let stat = detailPokemon.stats.first {
                    let effort = stat.base_stat
                    let progress = Float(effort) / 100.0
                    self.tastProgres.progress = progress
                }
                
                self.heightLabel.text = "\(self.detailPokemon?.height ?? 0)"
                self.weightLabel.text = "\(self.detailPokemon?.weight ?? 0)"
                self.idLabel.text = "#\(self.detailPokemon?.id ?? 0)"
                self.specLabel.text = self.detailPokemon?.species.name
                
                let typeNames = self.detailPokemon?.types.map { $0.type.name }
                let typesText = typeNames?.joined(separator: ", ") ?? ""
                self.typeLabel.text = typesText
                
                let abilityNames = self.detailPokemon?.abilities.map { $0.ability.name }
                let abilitiesText = abilityNames?.joined(separator: ", ") ?? ""
                self.speciesLabel.text = abilitiesText
            }
        }
        
        nameLabel.text = pokemonName
        
        if let imageUrl = pokemonImgURL {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageUrl),
                   let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
        }
    }
    
    // save data ke data core
    @IBAction func saveToFavorites(_ sender: Any) {
        guard let context = appDelegate?.persistentContainer.viewContext else { return }
        
        // Cek duplikasi data
        if let existingPokemon = fetchExistingFavoritePokemon(name: pokemonName, context: context) {
            showAlert(title: "Gagal", message: "\(existingPokemon.name ?? "Pokemon") sudah ada dalam pokemon andalan.")
            return
        }
        
        let favoritePokemon = FavoritePokemon(context: context)
        favoritePokemon.name = pokemonName
        favoritePokemon.id = Int32(detailPokemon?.id ?? 0)
        favoritePokemon.height = Double(detailPokemon?.height ?? 0)
        favoritePokemon.weight = Double(detailPokemon?.weight ?? 0)
        favoritePokemon.species = detailPokemon?.species.name
        favoritePokemon.imageUrl = pokemonImgURL?.absoluteString
        
        if let typeNames = detailPokemon?.types.map({ $0.type.name }) {
            let typesText = typeNames.joined(separator: ", ")
            favoritePokemon.type = typesText
        }
        
        do {
            try context.save()
            print("Favorite Pokemon saved successfully")
            showAlert(title: "Berhasil", message: "Pokemon menjadi favorite Anda.")
            
        } catch let error {
            print("Gagal save ke favorite pokemon:", error)
            showAlert(title: "Error", message: "Gagal menyimpan ke favorite pokemon.")
        }
    }
    
    // Fungsi mencari duplikasi dari nama
    func fetchExistingFavoritePokemon(name: String, context: NSManagedObjectContext) -> FavoritePokemon? {
        let fetchRequest: NSFetchRequest<FavoritePokemon> = FavoritePokemon.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let existingPokemon = try context.fetch(fetchRequest).first
            return existingPokemon
        } catch let error {
            print("Gagal mencari data duplikasi:", error)
            return nil
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Mantap!", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
}

