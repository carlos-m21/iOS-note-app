import SwiftUI
import UniformTypeIdentifiers
import AVFoundation
import CoreMedia
struct AddNoteView: View {
    @EnvironmentObject var store: NoteStore
    @EnvironmentObject var fontManager: FontManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var form: NoteForm
    @ObservedObject var audioRecorder = AudioRecorder()
    @ObservedObject var audioPlayer = AudioPlayer()
    @State var isImporting: Bool = false
    @State private var document: MessageDocument?
    
    @ObservedObject var timerManager = TimerManager()

    var body: some View {
        VStack {
            TextEditor(text: $form.text)
                .font(fontManager.appfont)
                .disabled(audioPlayer.isPlaying || audioRecorder.recording)
            if "" != form.file {
                HStack(alignment: .center, spacing: 8, content: {
                    Text(getLength(form.file))
                    Spacer()
                    if audioPlayer.isPlaying == false {
                        HStack {
                            Button(action: {
                                self.audioPlayer.startPlayback(audio: form.file)
                            }) {
                                Image(systemName: "play.circle")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                                    .foregroundColor(.blue)
                            }
                            .padding(.trailing, 8)
                            Button(action: {
                                let fileName = form.file
                                if fileName != "" {
                                    audioRecorder.deleteRecording(urlsToDelete: fileName)
                                }
                                form.file = ""
                            }) {
                                Image(systemName: "trash")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                                    .foregroundColor(.blue)
                            }
                        }
                    } else {
                        Button(action: {
                            self.audioPlayer.stopPlayback()
                        }) {
                            Image(systemName: "stop.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                                .foregroundColor(.blue)
                        }
                    }
                })
                .padding(32)

            } else {
                HStack(alignment: .center, spacing: 8, content: {
                    Text(timeFormat(timerManager.secondsElapsed))
                    Spacer()
                    if audioRecorder.recording == false {
                        Button(
                            action: {
                                print(self.audioRecorder.startRecording())
                                self.timerManager.start()
                            }
                        ) {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 32, height: 32)
                                .clipped()
                                .foregroundColor(.red)
                        }

                    } else {
                        Button(
                            action: {
                                let url = self.audioRecorder.stopRecording()
                                self.timerManager.stop()
                                print(url)
                                form.file = url
                            }
                        ) {
                            Image(systemName: "stop.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 32, height: 32)
                                .clipped()
                                .foregroundColor(.red)
                        }
                    }
                })
                .padding(32)

            }
            Spacer()
        }
        .navigationBarTitle("New Note", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            if form.updating {
                store.updateNote(note: form)
            } else {
                store.addNote(note: form)
            }
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Done")
        }))
        .toolbar(content: {
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    self.isImporting = true
                }, label: {
                    Image(systemName: "paperclip")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                })
                .frame(width: appConstants.bottomButtonSize, height: appConstants.bottomButtonSize)
                .padding()
            }
        })
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [UTType.audio],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFile: URL = try result.get().first else { return }
                
                //trying to get access to url contents
                if (CFURLStartAccessingSecurityScopedResource(selectedFile as CFURL)) {
                    let fileName = selectedFile.lastPathComponent
                    let data = try Data(contentsOf: selectedFile)
                    let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let audioFilename = documentPath.appendingPathComponent(fileName)
                    try data.write(to: audioFilename)
                    //done accessing the url
                    form.file = audioFilename.lastPathComponent
                    CFURLStopAccessingSecurityScopedResource(selectedFile as CFURL)
                }
                else {
                    print("Permission error!")
                }
            } catch {
                // Handle failure.
                print(error.localizedDescription)
            }
        }
    }
}

struct AddNoteView_Previews: PreviewProvider {
    static var test:String = ""
    static var testBinding = Binding<String>(get: { test }, set: {test = $0 } )
    static var previews: some View {
        AddNoteView(form: NoteForm(f: Folder(folder: FolderDB(), realm: NoteStore.shared.realm), index: 0), audioRecorder: AudioRecorder())
    }
}

func getLength(_ audio: String?) -> String {
    guard let audio = audio else {
        print("note hasn't audio")
        return ""
    }
    
    let fileManager = FileManager.default
    var filePath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    filePath.appendPathComponent(audio)
    let asset = AVAsset(url: filePath)

    let duration = asset.duration
    let durationTime = CMTimeGetSeconds(duration)
//    print(durationTime)

    let seconds = Int(durationTime) % 60
    let min = Int(durationTime / 60)
    return String(format: "%02d:%02d", min, seconds)
}

func timeFormat(_ durationTime: Double) -> String {
    let seconds = Int(durationTime) % 60
    let min = Int(durationTime / 60)
    return String(format: "%02d:%02d", min, seconds)
}

struct TimerButton: View {
    
    let label: String
    let buttonColor: Color
    
    var body: some View {
        Text(label)
            .foregroundColor(.white)
            .padding(.vertical, 20)
            .padding(.horizontal, 90)
            .background(buttonColor)
            .cornerRadius(10)
    }
}
