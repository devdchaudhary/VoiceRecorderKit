//
//  ContentView.swift
//  CustomAudioRecorder
//
//  Created by devdchaudhary on 28/04/23.
//

import SwiftUI
    
struct RecordingBarView: View {
    
    let numberOfSamples = 12
    var value: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.primaryText)
            .frame(width: 10, height: value)
    }
}

public struct AudioRecorderView: View {
    
    @StateObject private var audioRecorder = AudioRecorder(numberOfSamples: 15)
    @StateObject private var player = AudioPlayer(numberOfSamples: 15)
    
    @GestureState private var dragState: CGSize = .zero
    
    @State private var isRecording = false
    
    @State private var timer: Timer?
    @State private var recordingTimer: Timer?
    
    @State private var currentTime = 0
    @State private var holdingTime = 0
    @State private var isSendingAudio = false
    @State private var isLocked = false
    @State private var dragValue: CGSize?
        
    public init(isRecording: Bool = false, timer: Timer? = nil, recordingTimer: Timer? = nil, currentTime: Int = 0, holdingTime: Int = 0, isSendingAudio: Bool = false, isLocked: Bool = false, dragValue: CGSize? = nil) {
        self.isRecording = isRecording
        self.timer = timer
        self.recordingTimer = recordingTimer
        self.currentTime = currentTime
        self.holdingTime = holdingTime
        self.isSendingAudio = isSendingAudio
        self.isLocked = isLocked
        self.dragValue = dragValue
    }
    
    public var body: some View {
        
        if isRecording {
            
            HStack {
                
                Button {
                    if isRecording {
                        if isLocked {
                            withAnimation {
                                cancelRecording()
                            }
                        }
                    }
                } label: {
                    Image(systemName: "trash.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(dragState.height >= -45 ? .primaryText : .red)
                }
                .buttonStyle(.plain)
                .padding(.leading, 5)
                
                Spacer()
                
                Text(dragState.width >= 200 || isLocked ? "Slide to the right lock" : "Press and hold to record")
                    .foregroundColor(.primaryText)
                    .font(.system(size: 15))
                
                Spacer()
                
            }
            
            Spacer().frame(height: 20)
            
        }
        
        HStack {
            
            ZStack {
                
                if isLocked {
                    
                    Button {
                        withAnimation {
                            stopRecording()
                        }
                    } label: {
                        Image(systemName: "mic.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.primaryText)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                    
                } else {
                    
                    Button(action: {}) {
                        Image(systemName: "mic.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.primaryText)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 5)
                    .padding(.vertical, 8)
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 3)
                            .sequenced(before: DragGesture())
                            .updating($dragState) { value, dragState, _ in
                                switch value {
                                case .first:
                                    dragState = .zero
                                case .second(true, let drag):
                                    dragState = drag?.translation ?? .zero
                                default:
                                    break
                                }
                            }
                            .onEnded { value in
                                switch value {
                                case .first:
                                    dragValue = .zero
                                case .second(true, let drag):
                                    withAnimation {
                                        dragValue = drag?.translation ?? .zero
                                    }
                                default:
                                    break
                                }
                            }
                    )
                    .onLongPressGesture(perform: {}) { isPressing in
                        
                        if isPressing {
                            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                                withAnimation {
                                    holdingTime += 1
                                    if holdingTime == 3 {
                                        withAnimation {
                                            startRecording()
                                        }
                                    }
                                }
                            })
                            
                        } else {
                            
                            if holdingTime < 3 {
                                
                                holdingTime = 0
                                timer?.invalidate()
                                DropView.showWarning(title: "Hold to record", subtitle: "You must hold for atleast 2 seconds")
                                return
                            }
                            
                            if let value = dragValue {
                                
                                if value.height.magnitude >= 45 {
                                    
                                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                    impactMed.impactOccurred()
                                    
                                    withAnimation {
                                        cancelRecording()
                                    }
                                    
                                    dragValue = nil
                                    return
                                }
                                
                                if value.width.magnitude >= 150 {
                                    
                                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                    impactMed.impactOccurred()
                                    
                                    withAnimation {
                                        isLocked = true
                                    }
                                    
                                    dragValue = nil
                                    return
                                }
                            }
                            
                            withAnimation {
                                stopRecording()
                            }
                            dragValue = nil
                        }
                    }
                }
            }
            
            if isRecording {
                
                ZStack(alignment: .leading) {
                    
                    if dragState.width >= 200 || isLocked {
                        
                        HStack {
                            
                            Spacer()
                            
                            Text(currentTime.description)
                                .font(.system(size: 18))
                                .foregroundColor(.primaryText)
                                .padding(.horizontal)
                            
                            Button(action: {}) {
                                Image(systemName: "lock.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.primaryText)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                            
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(30)
                        
                    } else {
                        
                        HStack {
                            
                            Spacer()
                            
                            Text(currentTime.description)
                                .font(.system(size: 18))
                                .foregroundColor(.primaryText)
                                .padding(.horizontal)
                            
                            Image(systemName: "circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.red)
                                .frame(width: 5, height: 5)
                                .opacity(currentTime % 2 == 0 ? 1 : 0)
                            
                            Button(action: {}) {
                                Image(systemName: "lock.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.primaryText)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                            
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .cornerRadius(30)
                        
                    }
                    
                    HStack(spacing: 4) {
                        ForEach(audioRecorder.soundSamples, id: \.id) { level in
                            RecordingBarView(value: normalizeSoundLevel(level: Float(level.sample)))
                        }
                    }
                    .padding(.leading)
                    
                }
            }
            
            Spacer()
            
        }
        .padding(.horizontal)
        .padding(.vertical)
        .background(Color.backgroundColor.ignoresSafeArea(edges: .bottom))
        
    }
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 50) / 2 // between 0.1 and 25
        
        return CGFloat(level) // scaled to max at 300 (our height of our bar)
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
    
    private func startRecording() {
        isRecording = true
        timer?.invalidate()
        audioRecorder.startRecording()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            withAnimation {
                currentTime += 1
                if currentTime >= 60 {
                    stopRecording()
                }
            }
        })
    }
    
    func fetchRecordings() {
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try? fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
        
        if let directoryContents {
            
            for audio in directoryContents {
                let recording = Recording(fileURL: audio)
                player.recordings.append(recording)
            }
        }
    }
    
    func cancelRecording() {
        
        recordingTimer?.invalidate()
        
        guard let tempUrl = UserDefaults.standard.string(forKey: "tempUrl") else { return }
        
        if let url = URL(string: tempUrl) {
            
            audioRecorder.deleteRecording(url: url, onSuccess: nil)
        }
        
        audioRecorder.stopMonitoring()
        currentTime = 0
        isRecording = false
        isLocked = false
        holdingTime = 0
    }
    
    func stopRecording() {
        recordingTimer?.invalidate()
        audioRecorder.stopRecording()
        currentTime = 0
        isRecording = false
        isSendingAudio = true
        isLocked = false
        holdingTime = 0
        
        guard let tempUrl = UserDefaults.standard.string(forKey: "tempUrl") else { return }
        
        if let url = URL(string: tempUrl) {
            
            let newRecording = Recording(fileURL: url)
            
            player.recordings.append(newRecording)
        }
    }
}

struct AudioRecorderView_Previews: PreviewProvider {
    static var previews: some View {
        AudioRecorderView()
    }
}
