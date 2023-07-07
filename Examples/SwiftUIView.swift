//
//  SwiftUIView.swift
//  
//
//  Created by devdchaudhary on 29/06/23.
//

import SwiftUI

struct SwiftUIView: View {
    
    @StateObject var recorder = AudioRecorder()
    @StateObject var audioPlayer = AudioPlayer()
    
    var body: some View {
        VStack {
            List {
                ForEach(audioPlayer.recordings, id: \.uid) { recording in
                    VoicePlayerView(audioPlayer: audioPlayer, audioUrl: recording.fileURL)
                }
                .onDelete { indexSet in
                    delete(at: indexSet)
                }
            }
            Spacer()
            VoiceRecorderView(audioRecorder: recorder, player: audioPlayer)
        }
        .onAppear {
            recorder.fetchRecordings()
        }
    }
    
    func delete(at offsets: IndexSet) {
        
        if player.isPlaying {
            player.stopPlayback()
        }
        
        var recordingIndex: Int = 0
        
        for index in offsets {
            recordingIndex = index
        }
        
        let recording = player.recordings[recordingIndex]
        audioRecorder.deleteRecording(url: recording.fileURL, onSuccess: {
            player.recordings.remove(at: recordingIndex)
            DropView.showSuccess(title: "Recording removed!")
        })
        
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
