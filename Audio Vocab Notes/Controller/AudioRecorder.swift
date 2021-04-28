//
//  AudioRecorder.swift
//  Audio Vocab Notes
//
//  Created by welcome on 12/13/20.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

func getCreationDate(for file: URL) -> Date {
    if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
        let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
        return creationDate
    } else {
        return Date()
    }
}

struct Recording {
    let fileURL: URL
    let createdAt: Date
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

}

class AudioRecorder: NSObject,ObservableObject {
    
    override init() {
        super.init()
        fetchRecordings()
    }
    
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    
    var audioRecorder: AVAudioRecorder!
    
    var recordings = [Recording]()
    
    var recording = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.record()

            recording = true
        } catch {
            print("Could not start recording")
        }
    }
    
    func stopRecording() -> String {
        audioRecorder.stop()
        recording = false
        
        fetchRecordings()
        
        return audioRecorder.url.lastPathComponent
    }
    
    func fetchRecordings() {
        recordings.removeAll()
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
        for audio in directoryContents {
            let recording = Recording(fileURL: audio, createdAt: getCreationDate(for: audio))
            recordings.append(recording)
        }
        
        recordings.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending})
        
        objectWillChange.send(self)
    }
    
    func deleteRecording(urlsToDelete: String) {
        let fileManager = FileManager.default
        var filePath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        filePath.appendPathComponent(urlsToDelete)

        do {
           try FileManager.default.removeItem(at: filePath)
        } catch {
            print("File could not be deleted!")
        }

//        for url in urlsToDelete {
//            print(url)
//            do {
//               try FileManager.default.removeItem(at: url)
//            } catch {
//                print("File could not be deleted!")
//            }
//        }
//
//        fetchRecordings()
    }
    
}

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    let objectWillChange = PassthroughSubject<AudioPlayer, Never>()
    @Published var isPlaying = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    @Published var selectedNote: Note? {
        didSet {
            objectWillChange.send(self)
        }
    }

    var audioPlayer: AVAudioPlayer!
    var isFolderPlay: Bool = false
    var currentIndex: Int = 0
    var audioNotes: [Note] = []
    var isLoop: Bool = false

    func startPlayback (audio: String?) {
        
        guard let audio = audio else {
            print("note hasn't audio")
            return
        }
        if audioPlayer != nil {
            audioPlayer.stop()
        }
        
        let fileManager = FileManager.default
        var filePath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        filePath.appendPathComponent(audio)

        let playbackSession = AVAudioSession.sharedInstance()
        
        do {
            try playbackSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch let err {
            print(err.localizedDescription)
            print("Playing over the device's speakers failed")
        }
        
        do {
            print("\(audio) -> \(isLoop)")
            audioPlayer = try AVAudioPlayer(contentsOf: filePath)
            audioPlayer.delegate = self
            audioPlayer.play()
            isPlaying = true
        } catch let err {
            print(err.localizedDescription)
            print("Playback failed.")
        }
    }
    
    func startFolderPlayer (_ folder: Folder) {
        
        let audioNotes = folder.notes.filter { (note) -> Bool in
            return note.file != ""
        }
        if audioNotes.count == 0 {
            return
        }
        self.audioNotes = audioNotes
        isFolderPlay = true
        currentIndex = 0
        let audio = self.audioNotes[currentIndex].file
        self.selectedNote = self.audioNotes[currentIndex]
        self.startPlayback(audio: audio)

    }
    
    func stopPlayback() {
        if audioPlayer != nil {
            audioPlayer.stop()
        }
        self.selectedNote = nil
        isPlaying = false
        isFolderPlay = false
        self.audioNotes = []
        self.currentIndex = 0
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if isFolderPlay {
            if currentIndex < (self.audioNotes.count - 1) {
                currentIndex = currentIndex + 1
            } else {
                currentIndex = 0
            }
            self.selectedNote = self.audioNotes[currentIndex]
            self.startPlayback(audio: self.audioNotes[currentIndex].file)
        } else if isLoop {
            self.audioPlayer.play()
        } else {
            isPlaying = false
        }
    }
    
}
