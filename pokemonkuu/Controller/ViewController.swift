import UIKit

class ViewController: UIViewController {
    
    var data = [Pokemon]()
    
    var nextURL: URL?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchPokemonList(url: URL(string: "https://pokeapi.co/api/v2/pokemon")!)
        
    }
    
    // Fetch Pokemon list from URL
    func fetchPokemonList(url: URL) {
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let pokemonListResponse = try JSONDecoder().decode(PokemonListResponse.self, from: data)
                self.data += pokemonListResponse.results
                self.nextURL = pokemonListResponse.next
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            } catch {
                print("Error decoding response: \(error)")
            }
        }
        
        dataTask.resume()
    }
    
    func loadMorePokemon() {
        guard let nextURL = nextURL else {
            return
        }
        
        fetchPokemonList(url: nextURL)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyCollectionViewCell
        let pokemon = data[indexPath.item]
        cell.titleLabel.text = pokemon.name
        
        let imageUrlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(indexPath.item + 1).png"
        if let imageUrl = URL(string: imageUrlString) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageUrl),
                   let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        // Ensure the cell is still displaying the same Pokemon
                        if collectionView.indexPath(for: cell) == indexPath {
                            cell.imageView.image = image
                        }
                    }
                }
            }
        }
        
        cell.backgroundColor = UIColor.darkGray
        cell.layer.cornerRadius = 8
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.size.width - 10) / 2
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastIndex = collectionView.numberOfItems(inSection: 0) - 1
        if indexPath.item == lastIndex {
            loadMorePokemon()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let strbd = UIStoryboard(name: "Main", bundle: nil)
        guard let detailViewController = strbd.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        let selectedPokemon = data[indexPath.item]
        detailViewController.pokemonName = selectedPokemon.name
        detailViewController.pokemonUrl = selectedPokemon.url.absoluteString
        
        let imageUrlString = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(indexPath.item + 1).png"
        detailViewController.pokemonImgURL = URL(string: imageUrlString)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
