import UIKit

class ViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var sizeButtons: [UIButton]!
    @IBOutlet var quantityLabel: UILabel!
    @IBOutlet var orderButton: UIButton!

    private let drink = Menu.flatWhite
    private var sizeIndex = 1
    private var quantity = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = drink.name
        descriptionLabel.text = drink.description
        refresh()
    }

    @IBAction func sizeTapped(_ sender: UIButton) {
        sizeIndex = sender.tag
        refresh()
    }

    @IBAction func minusTapped(_ sender: UIButton) {
        quantity = max(1, quantity - 1)
        refresh()
    }

    @IBAction func plusTapped(_ sender: UIButton) {
        quantity = min(99, quantity + 1)
        refresh()
    }

    @IBAction func orderTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Added to order",
                                      message: "\(quantity) × \(drink.name)",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func refresh() {
        let unitPrice = drink.sizes[sizeIndex].price
        sizeButtons.forEach { $0.isSelected = ($0.tag == sizeIndex) }
        priceLabel.text = unitPrice.tenge
        quantityLabel.text = "\(quantity)"
        orderButton.setTitle("Add to order · \((unitPrice * quantity).tenge)", for: .normal)
    }
}
