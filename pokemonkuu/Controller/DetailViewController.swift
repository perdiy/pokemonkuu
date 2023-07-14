//
//  DetailViewController.swift
//  pokemonkuu
//
//  Created by Perdi Yansyah on 12/07/23.
//

import UIKit

class DetailViewController: UIViewController {
    var pokemonName: String = ""
    
    var pokemonImgURL: URL?
    
    var pokemonUrl: String = ""
    
    var ability: [Ability] = []
    
    var detailPokemon: DetailPokemon?
    
    
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
                
                self.heightLabel.text = "\(detailPokemon.height)"
                
                self.weightLabel.text = "\(detailPokemon.weight)"
                
                self.idLabel.text = "#\(detailPokemon.id)"
                
                self.specLabel.text = detailPokemon.species.name
                
                let typeNames = detailPokemon.types.map { $0.type.name }
                let typesText = typeNames.joined(separator: ", ")
                self.typeLabel.text = typesText
                
                let abilityNames = detailPokemon.abilities.map { $0.ability.name }
                let abilitiesText = abilityNames.joined(separator: ", ")
                self.speciesLabel.text = "\(abilitiesText)"
                
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
}

