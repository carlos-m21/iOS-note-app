import SwiftUI

struct NotesView: View {
    @EnvironmentObject var store: NoteStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var noteManager: NoteCountManager
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var toggleMaanger: ToggleModel
    @StateObject var storeManager: StoreManager

    var folder: Folder
    @State private var search = ""
    @State var editMode = EditMode.inactive
    @State var addNote = false
    @State var selectedNote: Note?
    @State var editNote = false
    @State var isLoop = false
    @ObservedObject var audioPlayer = AudioPlayer()
    @State var selectedLoop: Note?
    @State var showPurchase = false
    @State var shouldPurchase = false
    @State var isFolderPlaying = false

    var searchResult: [Note] {
        get {
            if self.search == "" {
                return folder.notes
            }
            return folder.notes.filter { (note) -> Bool in
                return note.text.lowercased().contains(search.lowercased())
            }
        }
    }

    var audioNotes: [Note] {
        get {
            return folder.notes.filter { (note) -> Bool in
                return note.file != ""
            }
        }
    }

    func getIsSelected(_ note: Note) -> Bool {
        if let sel = audioPlayer.selectedNote {
            return sel.id == note.id && audioPlayer.isPlaying
        } else if let selectedNote = self.selectedNote {
            return selectedNote.id == note.id && audioPlayer.isPlaying
        } else {
            return false
        }
    }

    var body: some View {
        ZStack {
            NavigationLink(
                destination: AddNoteView(form: NoteForm(f: self.folder, index: self.folder.count), audioRecorder: AudioRecorder()).environmentObject(store),
                isActive: $addNote,
                label: {
                    EmptyView()
                }).isDetailLink(false)
            
            if selectedNote != nil {
                NavigationLink(
                    destination: AddNoteView(form: NoteForm(self.selectedNote!), audioRecorder: AudioRecorder()).environmentObject(store),
                    isActive: $editNote
                ) {
                    EmptyView()
                }.isDetailLink(false)
            }
            
            VStack {
                SearchBar(text: $search)

                List {
                    ForEach(searchResult, id: \.id) { note in
                        NoteRow(data: note, isSelected: getIsSelected(note), isLoop: isLoop, isEdit: editMode == .active, onEdit: { (_) in
                            print("on Edit")
                            if let sel = selectedNote {
                                if sel.id == note.id {
                                    if !audioPlayer.isPlaying {
                                        isLoop = true
                                        audioPlayer.isLoop = isLoop
                                        audioPlayer.startPlayback(audio: sel.file)
                                    } else {
                                        isLoop = !isLoop
                                        audioPlayer.isLoop = isLoop
                                    }
                                } else {
                                    isLoop = true
                                    audioPlayer.isLoop = isLoop
                                    selectNote(note)
                                }
                            } else {
                                isLoop = true
                                audioPlayer.isLoop = isLoop
                                selectNote(note)
                            }
                        }, onTap: {(isPlaying) in
                            if editMode == .active {
                                self.editNote.toggle()
                                self.selectedNote = note
                                self.stopAudio()
                            } else {
                                self.selectNote(note)
                            }
                        })
                    }
                    .onMove(perform: onMove)
                    .onDelete(perform: onDelete)
                }
                .environment(\.editMode, $editMode)
                .listStyle(InsetGroupedListStyle())
            }
            
            if storeManager.isLoading {
                ActivityIndicatorView(isVisible: .constant(true), type: .default)
                    .frame(width: 36, height: 36)
                    .foregroundColor(toggleMaanger.isDark ? .white: .black)
            }
        }
        .navigationBarTitle(folder.title)
        .navigationBarItems(
            trailing: HStack {
                if !noteManager.purchased {
                    Button(action: {
                        if storeManager.myProducts.count > 0 {
                            shouldPurchase.toggle()
                        }
                    }, label: {
                        Image(systemName: "crown")
                    })
                    .padding(.all, 4)
                }
                Button(action: {
                    editMode = editMode.isEditing ? .inactive : .active
                    self.stopAudio()
                }, label: {
                    Text(editMode == .active ? "Done": "Edit Note")
                })
            }
        )
        .toolbar(content: {
            ToolbarItem(id: "", placement: .bottomBar) {
                if self.audioNotes.count > 0 {
                    Button {
                        isLoop = false
                        
                        if isFolderPlaying {
                            isFolderPlaying = false
                            audioPlayer.stopPlayback()
                        } else {
                            audioPlayer.stopPlayback()
                            isFolderPlaying = true
                            self.audioPlayer.startFolderPlayer(folder)
                        }
                    } label: {
                        Text(isFolderPlaying ? "Stop": "Play all")
                    }
                } else {
                    Spacer()
                }

            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    if store.getNotesCount() < 10 || noteManager.getPurchased() {
                        withAnimation {
                            addNote.toggle()
                            self.stopAudio()
                        }
                    } else {
                        withAnimation {
                            showPurchase.toggle()
                            self.stopAudio()
                        }
                    }
                }, label: {
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                })
                .frame(width: appConstants.bottomButtonSize, height: appConstants.bottomButtonSize)
                .padding()
            }
        })
        .alert(isPresented: $showPurchase) {
            Alert(title: Text("Purchase"), message: Text(purchaseDescription), primaryButton: .destructive(Text("Confirm")) {
                if storeManager.myProducts.count > 0 {
                    shouldPurchase.toggle()
                }
            }, secondaryButton: .cancel())
        }
        .actionSheet(isPresented: $shouldPurchase, content: {
            ActionSheet(
                title: Text("Pro Version"),
                message: Text("Unlock to limited capability."),
                buttons: [
                    .default(Text("Purchase to Pro \(storeManager.myProducts[0].priceLocale.currencySymbol!)\(storeManager.myProducts[0].price)"), action: {
                        if storeManager.myProducts.count > 0 {
                            self.storeManager.purchaseProduct(product: storeManager.myProducts[0], noteManager: noteManager)
                        }
                    }),
                    .default(Text("Restore"), action: {
                        if storeManager.myProducts.count > 0 {
                            self.storeManager.restoreProducts()
                        }
                    }),
                    .cancel()
                ]
            )
        })
        .onDisappear {
            audioPlayer.stopPlayback()
        }

    }
    
    func selectNote(_ note: Note) {
        if note.file != "" {
            if selectedNote == nil {
                self.selectedNote = note
            } else {
                if self.selectedNote?.id != note.id {
                    self.selectedNote = note
                } else {
                    self.selectedNote = nil
                }
            }
//            print("play audio -> \(self.selectedNote!)")
            self.playAudio()
        } else {
            print("No audio file")
        }
    }
    
    func getLoop(_ note: Note) -> Bool {
        if let sel = selectedLoop {
            return sel.id == note.id
        }
        return false
    }
    
    func playAudio() {
        self.stopAudio()
        if let selected = self.selectedNote {
            if selected.file != "" {
                audioPlayer.isLoop = isLoop
                print("start audio -> \(selected.file)")
                audioPlayer.startPlayback(audio: selected.file)
            } else {
                self.selectedNote = nil
                print("stop audio -> ")
                audioPlayer.stopPlayback()
            }
        } else {
            print("stop audio -> ")
            audioPlayer.stopPlayback()
        }
    }
    
    func stopAudio() {
        isFolderPlaying = false
        if audioPlayer.isPlaying {
            audioPlayer.stopPlayback()
        }
    }
    
    private func onDelete(at offsets: IndexSet) {
        // preserve all ids to be deleted to avoid indices confusing
        let idsToDelete = offsets.map { searchResult[$0] }
        
        for i in idsToDelete {
            store.deleteNote(note: i)
        }
    }
    
    private func onMove(source: IndexSet, destination: Int) {
        var temp = folder.notes
        temp.move(fromOffsets: source, toOffset: destination)
        for i in 0..<temp.count {
            store.updateNote(note: NoteForm(temp[i], index: i))
        }
    }

}
