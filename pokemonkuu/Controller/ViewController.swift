//
//  ViewController.swift
//  pokemonkuu
//
//  Created by Perdi Yansyah on 12/07/23.
//

import UIKit

class ViewController: UIViewController {
    
    var viewModel = PokemonViewModel()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        // APIs
        viewModel.fetchData { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // kembalikan jumlah poke
        return viewModel.numberOfPokemon()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyCollectionViewCell
        let pokemon = viewModel.pokemon(at: indexPath.item)
        cell.titleLabel.text = pokemon.name
        // image pokemon
        viewModel.loadImageForPokemon(at: indexPath.item) { image in
            DispatchQueue.main.async {
                if collectionView.indexPath(for: cell) == indexPath {
                    cell.imageView.image = image
                }
            }
        }
        
        cell.layer.cornerRadius = 8
        cell.layer.cornerRadius = 8
        cell.layer.shadowRadius = 4
        cell.layer.shadowOpacity = 0.3
        cell.layer.masksToBounds = true
        cell.layer.masksToBounds = false
        cell.layer.shadowOffset = CGSizeMake(9, 9)
        cell.layer.shadowColor = UIColor.black.cgColor
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.size.width - 10) / 2
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastIndex = collectionView.numberOfItems(inSection: 0) - 1
        if indexPath.item == lastIndex {
            // next url data pokemon
            viewModel.loadMorePokemon { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let strbd = UIStoryboard(name: "Main", bundle: nil)
        guard let detailViewController = strbd.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        let selectedPokemon = viewModel.pokemon(at: indexPath.item)
        detailViewController.pokemonName = selectedPokemon.name
        detailViewController.pokemonUrl = selectedPokemon.url.absoluteString
        let imageUrlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(indexPath.item + 1).png"
        detailViewController.pokemonImgURL = URL(string: imageUrlString)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
