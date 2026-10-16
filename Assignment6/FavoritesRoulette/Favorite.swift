import Foundation

struct Favorite {
    let imageName: String
    let title: String
    let description: String
}

enum FavoritesStore {
    static let games: [Favorite] = [
        Favorite(imageName: "rdr2", title: "Red Dead Redemption 2",
                 description: "Arthur Morgan and the Van der Linde gang try to survive the end of the Wild West."),
        Favorite(imageName: "witcher3", title: "The Witcher 3: Wild Hunt",
                 description: "Geralt of Rivia hunts monsters and searches for his adopted daughter Ciri."),
        Favorite(imageName: "cyberpunk", title: "Cyberpunk 2077",
                 description: "A mercenary in Night City chases a chip that holds the key to immortality."),
        Favorite(imageName: "kingdomcome", title: "Kingdom Come: Deliverance I & II",
                 description: "A realistic medieval RPG about Henry, a blacksmith's son caught in a war for Bohemia."),
        Favorite(imageName: "skyrim", title: "The Elder Scrolls V: Skyrim",
                 description: "The Dragonborn returns to the frozen north to stop the dragon Alduin."),
        Favorite(imageName: "stardew", title: "Stardew Valley",
                 description: "Leave the city, restore your grandfather's farm and build a new life."),
        Favorite(imageName: "disco", title: "Disco Elysium",
                 description: "A washed-up detective with amnesia solves a murder in a city full of politics."),
        Favorite(imageName: "expedition33", title: "Clair Obscur: Expedition 33",
                 description: "A turn-based RPG where an expedition tries to stop the Paintress before she erases everyone."),
        Favorite(imageName: "lastofus", title: "The Last of Us",
                 description: "Joel escorts teenage Ellie across a post-apocalyptic America."),
        Favorite(imageName: "alanwake2", title: "Alan Wake 2",
                 description: "An FBI agent and a lost writer fight a darkness that turns stories into reality.")
    ]
}
