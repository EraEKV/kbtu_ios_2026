import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var previousButton: UIButton!
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var nextButton: UIButton!

    private let tracks = TrackLibrary.tracks

    // Screen state: the whole UI is refreshed from these two values
    private var currentIndex = 0
    private var isPlaying = false

    // Stored on the controller so the player lives as long as the screen
    private var player: AVAudioPlayer?

    private var currentTrack: Track {
        tracks[currentIndex]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        configureButtonIcons()
        loadCurrentTrack()
        refreshUI()
    }

    // MARK: - Actions

    @IBAction func playPauseTapped(_ sender: UIButton) {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            startPlayback()
        }
        refreshUI()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        switchTrack(to: (currentIndex + 1) % tracks.count)
    }

    @IBAction func previousTapped(_ sender: UIButton) {
        switchTrack(to: (currentIndex - 1 + tracks.count) % tracks.count)
    }

    // MARK: - Playback

    private func switchTrack(to index: Int) {
        currentIndex = index
        loadCurrentTrack()
        // Keep the play state: if music was playing, the new track starts playing too
        if isPlaying {
            startPlayback()
        }
        refreshUI()
    }

    private func loadCurrentTrack() {
        player?.stop()
        player = nil

        guard let url = Bundle.main.url(forResource: currentTrack.fileName, withExtension: nil) else {
            print("Audio file \(currentTrack.fileName) is missing from the app bundle")
            return
        }

        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.delegate = self
            newPlayer.prepareToPlay()
            player = newPlayer
        } catch {
            print("Could not play \(currentTrack.fileName): \(error.localizedDescription)")
        }
    }

    private func startPlayback() {
        guard let player else {
            isPlaying = false
            showAlert(message: "Can't play \"\(currentTrack.title)\": the audio file \(currentTrack.fileName) is missing or broken.")
            return
        }
        player.play()
        isPlaying = true
    }

    // MARK: - UI

    // UIButton ignores the symbol size set in Interface Builder, so it is applied here (styling only, no layout)
    private func configureButtonIcons() {
        let sizes: [(UIButton, CGFloat)] = [(previousButton, 30), (playPauseButton, 50), (nextButton, 30)]
        for (button, pointSize) in sizes {
            button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: pointSize), forImageIn: .normal)
        }
    }

    private func refreshUI() {
        let cover = UIImage(named: currentTrack.coverImageName)
        coverImageView.image = cover
        // The blurred cover behind everything fades to the new track's colors
        UIView.transition(with: backgroundImageView, duration: 0.4, options: .transitionCrossDissolve) {
            self.backgroundImageView.image = cover
        }
        titleLabel.text = currentTrack.title
        artistLabel.text = currentTrack.artist
        playPauseButton.setImage(UIImage(systemName: isPlaying ? "pause.fill" : "play.fill"), for: .normal)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Playback error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - AVAudioPlayerDelegate

extension PlayerViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // isPlaying is still true here, so switchTrack starts the next track automatically
        switchTrack(to: (currentIndex + 1) % tracks.count)
    }
}
