import UIKit

class GameCell: UITableViewCell {

    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    // Five star image views, tagged 1...5 in the storyboard
    @IBOutlet var starImageViews: [UIImageView]!

    // Every field is set on each call, so a reused cell never keeps data from its previous game
    func configure(with game: Game) {
        coverImageView.image = UIImage(named: game.imageName)
        titleLabel.text = game.title
        subtitleLabel.text = game.subtitle
        for star in starImageViews {
            let isFilled = star.tag <= game.rating
            star.image = UIImage(systemName: isFilled ? "star.fill" : "star")
        }
    }
}
