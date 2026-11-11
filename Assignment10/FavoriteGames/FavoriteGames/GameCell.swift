import UIKit

class GameCell: UITableViewCell {

    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    // Every field is set on each call, so a reused cell never keeps data from its previous game
    func configure(with game: Game) {
        coverImageView.image = UIImage(named: game.imageName)
        titleLabel.text = game.title
    }
}
