//
//  SpeechRecorder.swift
//
//  Created by devdchaudhary on 18/04/23.
//

import SwiftUI
import AVFoundation

public final class AudioRecorder: NSObject, ObservableObject {
        
    @Published public var recordings: [Recording] = []
    @Published public var recording = false
    @Published public var soundSamples: [RecordingSampleModel]
    
    private var currentSample: RecordingSampleModel = .init(sample: .zero)
    private let numberOfSamples: Int

    private var timer: Timer?
    
    public var audioRecorder = AVAudioRecorder()
    
    let audioFormatID: AudioFormatID
    let sampleRateKey: Float
    let noOfchannels: Int
    let audioQuality: AVAudioQuality
    
    public init(numberOfSamples: Int, audioFormatID: AudioFormatID, audioQuality: AVAudioQuality, noOfChannels: Int = 2, sampleRateKey: Float = 44100.0) {
        self.soundSamples = [RecordingSampleModel](repeating: .init(sample: .zero), count: numberOfSamples)
        self.numberOfSamples = numberOfSamples
        self.audioFormatID = audioFormatID
        self.audioQuality = audioQuality
        self.noOfchannels = noOfChannels
        self.sampleRateKey = sampleRateKey
    }
    
    public func startRecording() {
                
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
    
    public func stopRecording() {
        audioRecorder.stop()
        recording = false
        stopMonitoring()
        saveRecording()
    }
    
    private func saveRecording() {
        if let tempUrl = UserDefaults.standard.string(forKey: "tempUrl") {
            if let url = URL(string: tempUrl) {
                if let data = try? Data(contentsOf: url) {
                    do {
                        try data.write(to: url, options: [.atomic, .completeFileProtection])
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    public func deleteRecording(url: URL, onSuccess: (() -> Void)?) {
        
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
    
    public func fetchRecordings() {
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try? fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
        
        if let directoryContents {
            
            for audio in directoryContents {
                let recording = Recording(fileURL: audio)
                recordings.append(recording)
            }
        }
    }
}
