//
//  AlarmsStopViewController.swift
//  task3_app
//
//  Created by Tolgahan Sonmez on 31.08.2023.
//

import UIKit
import AVFoundation

class AlarmStopViewController: UIViewController {
    
    var avPlayer: AVAudioPlayer?
    var loopCount = 0
    let maxLoopCount = 5
    let initialVolume: Float = 0.3
    let maxVolume: Float = 1.0
    let volumeIncrement: Float = 0.3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if let soundUrl = Bundle.main.url(forResource: "alarmSound", withExtension: "mp3") {
            do {
                avPlayer = try AVAudioPlayer(contentsOf: soundUrl)
                avPlayer?.prepareToPlay()
                avPlayer?.volume = initialVolume
                playMusicWithIncreasingVolume()
            } catch {
                print("Error playing sound: \(error.localizedDescription)")
            }
        }
    }
    
    func playMusicWithIncreasingVolume() {
        guard let avPlayer = avPlayer else { return }
        
        if loopCount < maxLoopCount {
            avPlayer.volume = Float(loopCount + 1) * volumeIncrement
            avPlayer.play()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + avPlayer.duration) {
                self.avPlayer?.pause()
                self.avPlayer?.currentTime = 0
                self.loopCount += 1
                self.playMusicWithIncreasingVolume()
            }
        }
    }
    
    @IBAction func turnoffButtonTapped(_ sender: UIButton) {
        avPlayer?.stop()
    }
}
