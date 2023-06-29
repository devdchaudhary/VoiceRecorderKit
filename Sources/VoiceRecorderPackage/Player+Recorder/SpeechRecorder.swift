//
//  SpeechRecorder.swift
//  RecosiaIOS
//
//  Created by devdchaudhary on 18/04/23.
//

import SwiftUI
import AVFoundation

class AudioRecorder: NSObject, ObservableObject {
        
    @Published var recording = false
    @Published public var soundSamples: [RecordingSampleModel]
    
    private var currentSample: RecordingSampleModel = .init(sample: .zero)
    private let numberOfSamples: Int

    private var timer: Timer?
    
    var audioRecorder = AVAudioRecorder()
    
    init(numberOfSamples: Int) {
        self.soundSamples = [RecordingSampleModel](repeating: .init(sample: .zero), count: numberOfSamples)
        self.currentSample = .init(sample: .zero)
        self.numberOfSamples = numberOfSamples
    }
    
    static let shared = AudioRecorder(numberOfSamples: 12)
    
    func startRecording() {
                
        do {
            
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch let error {
            
            print("Failed to set up recording session \(error.localizedDescription)")
        }
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath.appendingPathComponent("\(UUID().uuidString).m4a")
        
        UserDefaults.standard.set(audioFilename.absoluteString, forKey: "tempUrl")
                
        let settings: [String:Any] = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVSampleRateKey:44100.0,
            AVNumberOfChannelsKey:2,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.record()
            recording = true
            startMonitoring()
        } catch {
            print("Could not start recording")
        }
    }
    
    func stopRecording() {
        audioRecorder.stop()
        recording = false
        stopMonitoring()
    }
    
    func deleteRecording(url: URL, onSuccess: (() -> Void)?) {
        
        do {
            try FileManager.default.removeItem(at: url)
            onSuccess?()
        } catch {
            print("File could not be deleted!")
        }
    }
    
    private func startMonitoring() {
        
        audioRecorder.isMeteringEnabled = true

        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [weak self] _ in
            
            guard let this = self else { return }
            
            this.audioRecorder.updateMeters()
            this.soundSamples[this.currentSample.sample] = RecordingSampleModel(sample: Int(this.audioRecorder.averagePower(forChannel: 0)))
            this.currentSample.sample = (this.currentSample.sample + 1) % this.numberOfSamples
        })
    }
    
    func stopMonitoring() {
        audioRecorder.isMeteringEnabled = false
        timer?.invalidate()
    }
    
}
