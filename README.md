# VoiceRecorderPackage

A Package that uses UIScrollView to allow users to use a paging scrollView inside SwiftUI Views 
via the UIViewRepresentable Protocol

Requirements

iOS 15,
Swift 5.0
Xcode 13.0+

Installation

Swift Package Manager

To integrate VoiceRecorderPackage into your Xcode project, specify it in Package Dependancies > Click the "+" button > Copy and paste the URL below:

```https://github.com/devdchaudhary/VoiceRecorderPackage```

set branch to "master"

Check VoiceRecorderPackage

Click Add to Project

https://github.com/devdchaudhary/VoiceRecorder/assets/52855516/82a9408a-cec8-4559-a366-6608276f890e

Usage

Step 1 : Import ```VoiceRecorderPackage```

Step 2 : Declare the AudioRecorder Constructor as a ```@StateObject` and give input your desired settings for the voice output.

Step 3: Call the VoiceRecorderView inside your view and pass the ```@StateObject` to it.

Step 3 : Press and Hold the Record Button on the VoiceRecorderView

Below is an example demonstrating the use of the recorder and player.

```
import SwiftUI
import AudioUnit
import VoiceRecorderPackage

struct ContentView: View {
    
    @StateObject var recorder = AudioRecorder(numberOfSamples: 15, audioFormatID: kAudioFormatAppleLossless, audioQuality: .max)
        
    var body: some View {
        VStack {
            List {
                ForEach(recorder.recordings, id: \.uid) { recording in
                    VoicePlayerView(audioUrl: recording.fileURL)
                        .onAppear {
                            print(recording.fileURL)
                        }
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
            DropView.showSuccess(title: "Recording removed!")
        })
    }
}
```
