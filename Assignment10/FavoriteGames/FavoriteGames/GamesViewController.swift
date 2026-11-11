import UIKit

class GamesViewController: UIViewController, UITableViewDataSource {

    // Must match the prototype cell's reuse identifier in Main.storyboard
    private let cellIdentifier = "GameCell"
    // Must match the Show segue identifier in Main.storyboard
    private let detailSegueIdentifier = "showDetail"

    private let games = GameLibrary.games

    @IBOutlet private var tableView: UITableView!

    // Deselect the tapped row when coming back from the Detail screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }

    // Only data is passed forward; the Detail screen fills its own outlets
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == detailSegueIdentifier,
              let detailViewController = segue.destination as? DetailViewController,
              let indexPath = tableView.indexPathForSelectedRow else { return }
        detailViewController.item = games[indexPath.row]
    }

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
