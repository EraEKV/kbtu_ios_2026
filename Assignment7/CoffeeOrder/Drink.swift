import Foundation

struct Drink {
    struct Size {
        let price: Int
    }

    let name: String
    let description: String
    let sizes: [Size]
}

enum Menu {
    static let flatWhite = Drink(
        name: "Flat White",
        description: "Double ristretto with silky steamed milk. Smooth, strong and not too sweet.",
        sizes: [Drink.Size(price: 1600), Drink.Size(price: 1800), Drink.Size(price: 2000)]
    )
}

extension Int {
    var tenge: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return "₸" + (formatter.string(from: NSNumber(value: self)) ?? "\(self)")
    }
}
