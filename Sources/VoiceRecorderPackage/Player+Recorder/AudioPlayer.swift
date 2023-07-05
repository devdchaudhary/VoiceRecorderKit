//
//  AudioPlayer.swift
//  RecosiaIOS
//
//  Created by devdchaudhary on 18/04/23.
//

import SwiftUI
import AVFoundation

public final class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    @Published var recordings: [Recording] = []
    @Published var soundSamples: [SampleModel] = []
    @Published var isPlaying = false
    
    var audioPlayer = AVAudioPlayer()
    
    private var timer: Timer?
    
    private var currentSample: Float = 0
    private let numberOfSamples: Int
    
    private var durationTimer: Timer?
    
    var fileDuration: TimeInterval = 0
    var currentTime: Int = 0
        
    public init(isPlaying: Bool = false, audioPlayer: AVAudioPlayer = AVAudioPlayer(), timer: Timer? = nil, numberOfSamples: Int) {
        self.isPlaying = isPlaying
        self.audioPlayer = audioPlayer
        self.timer = timer
        self.numberOfSamples = numberOfSamples
    }
    
    func playSystemSound(soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
    
    func startPlayback(audio: URL) {
        
        do {
            
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: audio)
            audioPlayer.volume = 1.0
            audioPlayer.delegate = self
            audioPlayer.play()
            
            withAnimation {
                isPlaying = true
            }
            
            fileDuration = audioPlayer.duration.rounded()
            
            startMonitoring()
                        
        } catch let error {
            
            print("Playback failed.\(error.localizedDescription)")
            
        }
    }
    
    func startMonitoring() {
        
        audioPlayer.isMeteringEnabled = true
        currentTime = Int(fileDuration)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
            
            guard let this = self else { return }
            
            this.audioPlayer.updateMeters()
            this.currentSample = this.audioPlayer.peakPower(forChannel: 0)
            this.soundSamples.append(SampleModel(sample: this.currentSample))
        }
        
        durationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            
            guard let this = self else { return }
            
            this.currentTime -= 1
        }
        
    }
    
    private func stopMonitoring() {
        soundSamples = []
        audioPlayer.isMeteringEnabled = false
        timer?.invalidate()
        durationTimer?.invalidate()
        currentTime = Int(fileDuration)
    }
    
    func stopPlayback() {
        audioPlayer.stop()
        stopMonitoring()
        
        withAnimation {
            isPlaying = false
        }
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            stopPlayback()
        }
    }
    
}
