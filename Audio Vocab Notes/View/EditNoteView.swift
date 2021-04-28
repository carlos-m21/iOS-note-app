import SwiftUI

struct EditNoteView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var folder: Folder?
    @State var note: Note
    
    @ObservedObject var audioRecorder: AudioRecorder
    @ObservedObject var audioPlayer = AudioPlayer()

    var body: some View {
        VStack {
            TextEditor(text: $note.title)
            if "" != note.file {
                if audioPlayer.isPlaying == false {
                    Button(action: {
                        self.audioPlayer.startPlayback(audio: note.file)
                    }) {
                        Image(systemName: "play.circle")
                            .imageScale(.large)
                    }
                } else {
                    Button(action: {
                        self.audioPlayer.stopPlayback()
                    }) {
                        Image(systemName: "stop.fill")
                            .imageScale(.large)
                    }
                }
            } else {
                if audioRecorder.recording == false {
                    Button(
                        action: {
                            print(self.audioRecorder.startRecording()
                            )
                        }
                    ) {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .foregroundColor(.red)
                            .padding(.bottom, 40)
                    }
                } else {
                    Button(
                        action: {
                            let url = self.audioRecorder.stopRecording()
                            print(url)
                            note.file = url
                        }
                    ) {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .foregroundColor(.red)
                            .padding(.bottom, 40)
                    }
                }
            }
            Spacer()
        }
        .navigationBarTitle("Edit Note", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
//            folderManager.updateNote(id: note.id, title: note.title, file: note.file, folder: note.folder)
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Done")
        }))
    }
}

struct EditNoteView_Previews: PreviewProvider {
    static var test:String = ""//some very very very long description string to be initially wider than screen"
    static var testBinding = Binding<String>(get: { test }, set: {
//        print("New value: \($0)")
        test = $0 } )
    static var previews: some View {
        EditNoteView(note: Note(note: NoteDB()), audioRecorder: AudioRecorder())
    }
}
