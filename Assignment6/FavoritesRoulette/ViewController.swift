import UIKit

class ViewController: UIViewController {

    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var rollButton: UIButton!

    private let favorites = FavoritesStore.games
    private var currentIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let first = favorites.indices.first {
            show(at: first)
        }
    }

    @IBAction func rollTapped(_ sender: UIButton) {
        let candidates = favorites.indices.filter { $0 != currentIndex }
        guard let next = candidates.randomElement() else { return }
        show(at: next)
    }

    private func show(at index: Int) {
        let favorite = favorites[index]
        currentIndex = index
        posterImageView.image = UIImage(named: favorite.imageName)
        titleLabel.text = favorite.title
        descriptionLabel.text = favorite.description
    }
}
