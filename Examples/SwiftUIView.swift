//
//  SwiftUIView.swift
//  
//
//  Created by devdchaudhary on 29/06/23.
//

import SwiftUI

struct SwiftUIView: View {
    
    @StateObject var audioPlayer = AudioPlayer()
    
    var body: some View {
        VStack {
            ForEach(audioPlayer.recordings, id: \.uid) { recording in
                VoicePlayerView(audioPlayer: audioPlayer, audioUrl: recording.fileURL)
            }
            Spacer()
            VoiceRecorderView()
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
