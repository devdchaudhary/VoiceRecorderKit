# VoiceRecorderKit

A Package that uses AVFoundation to allow users to use a record and playback audio recorder via the device's mic and saves the recording audio files via FileManager.

It also uses a third party library known as "Drops" to give user feedback.

The View uses a ```@GestureState``` wrapper to persist the pressing state of the user and to check the drag value of the user.

It resets the value to zero when the user has stopped pressing on the screen.

The Player and Recorder View themselves use the 
```.averagePower()```
modifier to get the power input from the voice channel and use those to visualize a waveform of the audio.

Light Mode
![Simulator Screen Recording - iPhone 14 Pro - 2023-07-07 at 12 16 54](https://github.com/devdchaudhary/VoiceRecorderPackage/assets/52855516/02ea2cb5-efa2-45b5-85bd-a9b05f47379b)

Supports Dark Mode
![Simulator Screen Recording - iPhone 14 Pro - 2023-06-16 at 07 08 05](https://github.com/devdchaudhary/VoiceRecorder/assets/52855516/82a9408a-cec8-4559-a366-6608276f890e)

Requirements

iOS 15,
Swift 5.0
Xcode 13.0+

Installation

Swift Package Manager

To integrate VoiceRecorderPackage into your Xcode project, specify it in Package Dependancies > Click the "+" button > Copy and paste the URL below:

```https://github.com/devdchaudhary/VoiceRecorderPackage```

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
