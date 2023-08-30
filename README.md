# VoiceRecorderKit

A Package that uses AVFoundation to allow users to use a record and playback audio recorder via the device's mic and saves the recording audio files via FileManager.

It also uses a third party library known as "Drops" to give user feedback.

The View uses a ```@GestureState``` wrapper to persist the pressing state of the user and to check the drag value of the user.

It resets the value to zero when the user has stopped pressing on the screen.

The Player and Recorder View themselves use the 
```.averagePower()```
modifier to get the power input from the voice channel and use those to visualize a waveform of the audio.

Light Mode
![Simulator Screen Recording - iPhone 14 Pro - 2023-07-18 at 16 02 12](https://github.com/devdchaudhary/VoiceRecorderKit/assets/52855516/584f64e3-0d0f-4338-a359-e7b68a983481)


Supports Dark Mode
![Simulator Screen Recording - iPhone 14 Pro - 2023-07-18 at 16 02 57](https://github.com/devdchaudhary/VoiceRecorderKit/assets/52855516/bac6515f-9044-4f52-9d5f-2854f060d10e)


Requirements

iOS 15,
Swift 5.0
Xcode 13.0+

Installation

Swift Package Manager

To integrate VoiceRecorderPackage into your Xcode project, specify it in Package Dependancies > Click the "+" button > Copy and paste the URL below:

```https://github.com/devdchaudhary/VoiceRecorderKit```

set branch to "master"

Check VoiceRecorderKit

Click Add to Project

Usage

Step 1 : Import ```VoiceRecorderKit```

Step 2 : Declare the AudioRecorder Constructor as a ```@StateObject` and give input your desired settings for the voice output.

Step 3: Call the VoiceRecorderView inside your view and pass the ```@StateObject` to it.

Step 3 : Press and Hold the Record Button on the VoiceRecorderView

Below is an example demonstrating the use of the recorder and player.

```
import SwiftUI
import AudioUnit
import VoiceRecorderKit

struct ContentView: View {
    
    @StateObject var recorder = AudioRecorder(numberOfSamples: 12, audioFormatID: kAudioFormatAppleLossless, audioQuality: .max)
        
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
