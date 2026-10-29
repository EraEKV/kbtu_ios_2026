//
//  ViewController.swift
//  UIStackView
//
//  Created by Arman Myrzakanurov on 22.10.2026.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    private var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func soundDidTap(_ sender: UIButton) {
        guard let soundName = sender.titleLabel?.text else {
            print("Button title missed")
            return
        }
        playSoundIfPossible(soundName)
    }

    private func playSoundIfPossible(_ soundName: String) {
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "wav") else {
            // Print - log
            return
        }
        player = try? AVAudioPlayer(contentsOf: soundURL) // explicit error handling, to show user or log
        player?.play()
    }
}

