//
//  AudioPlayerView.swift
//  CustomAudioRecorder
//
//  Created by devdchaudhary on 11/05/23.
//

import SwiftUI

public struct VoicePlayerView: View {
    
    @ObservedObject var audioPlayer: AudioPlayer
    
    private var audioUrl: URL
    @State private var isPlaying = false
    
    @State private var timer: Timer?
    
    private var fileName: String?
    
    public init(audioPlayer: AudioPlayer, audioUrl: URL, isPlaying: Bool = false, timer: Timer? = nil, fileName: String? = nil) {
        self.audioPlayer = audioPlayer
        self.audioUrl = audioUrl
        self.isPlaying = isPlaying
        self.timer = timer
        self.fileName = fileName
    }
    
    public var body: some View {
        
        HStack {
            
            if audioPlayer.isPlaying {
                
                Button(action: stopPlaying) {
                    Image(systemName: "stop.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(uiColor: .systemRed))
                }
                .buttonStyle(.plain)
                
            } else {
                
                Button(action: playAudio) {
                    Image(systemName: "play.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(uiColor: .systemGreen))
                }
                .buttonStyle(.plain)
                
            }
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(audioPlayer.soundSamples, id: \.id) { level in
                            BarView(isRecording: false, sample: level)
                                .id(level)
                        }
                    }
                }
                .onChange(of: audioPlayer.soundSamples) { _ in
                    proxy.scrollTo(audioPlayer.soundSamples.last)
                }
            }
            
            Text(audioPlayer.currentTime.description)
                .font(.system(size: 18))
                .foregroundColor(.primaryText)
            
        }
        .padding()
        .padding(.vertical)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 1)
                .padding(.vertical)
            
        }
    }
    
    private func playAudio() {
        audioPlayer.playSystemSound(soundID: 1306)
        audioPlayer.startPlayback(audio: audioUrl)
    }
    
    private func stopPlaying() {
        audioPlayer.stopPlayback()
    }
    
}
