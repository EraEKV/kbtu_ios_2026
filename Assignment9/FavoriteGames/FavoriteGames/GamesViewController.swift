import UIKit

class GamesViewController: UIViewController, UITableViewDataSource {

    // Must match the prototype cell's reuse identifier in Main.storyboard
    private let cellIdentifier = "GameCell"

    private let games = GameLibrary.games

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        games.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! GameCell
        cell.configure(with: games[indexPath.row])
        return cell
    }
}
