import UIKit

class DetailViewController: UIViewController {

    // Set by the list screen in prepare(for:sender:)
    var item: Game?

    @IBOutlet private var coverImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    // Five star image views, tagged 1...5 in the storyboard
    @IBOutlet private var starImageViews: [UIImageView]!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let item else { return }
        title = item.title
        coverImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        descriptionLabel.text = item.description
        for star in starImageViews {
            star.image = UIImage(systemName: star.tag <= item.rating ? "star.fill" : "star")
        }
    }
}
