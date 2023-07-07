//
//  SwiftUIView.swift
//  
//
//  Created by devdchaudhary on 29/06/23.
//

import SwiftUI

struct SwiftUIView: View {
    
    @StateObject var recorder = AudioRecorder(numberOfSamples: 15, audioFormatID: kAudioFormatAppleLossless, audioQuality: .max)
        
    var body: some View {
        VStack {
            
            Text("My Recordings")
                .foregroundColor(.primaryText)
                .font(.system(size: 15)).bold()
            
            List {
                
                ForEach(recorder.recordings, id: \.uid) { recording in
                    VoicePlayerView(audioUrl: recording.fileURL)
                }
                .onDelete { indexSet in
                    delete(at: indexSet)
                }
            }
            .listStyle(.inset)
            Spacer()
            VoiceRecorderView(audioRecorder: recorder)
        }
        .onAppear {
            recorder.fetchRecordings()
        }
    }
    
    func delete(at offsets: IndexSet) {

        var recordingIndex: Int = 0

        for index in offsets {
            recordingIndex = index
        }

        let recording = recorder.recordings[recordingIndex]
        recorder.deleteRecording(url: recording.fileURL, onSuccess: {
            recorder.recordings.remove(at: recordingIndex)
        })
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
