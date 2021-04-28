import SwiftUI
import MobileCoreServices
import StoreKit
struct MainView: View {
    @EnvironmentObject var store: NoteStore
    @EnvironmentObject var noteManager: NoteCountManager
    @EnvironmentObject var toggleMaanger: ToggleModel
    @EnvironmentObject var fontManager: FontManager
    @StateObject var storeManager: StoreManager

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var editMode = EditMode.inactive
    let folders: [Folder]
    @State var newFolder = false
    @State var editFolder = false
    @State var selectedFolder: Folder?
    @State var search = ""
    @State var addNote = false
    @State var showPurchase = false
    @State var shouldPurchase = false
    var searchResult: [Folder] {
        get {
            if self.search == "" {
                return folders
            }
            return folders.filter { (f) -> Bool in
                return f.title.lowercased().contains(search.lowercased())
            }
        }
    }
    var body: some View {
        VStack {
            
            SearchBar(text: $search)
            
            if folders.isEmpty {
                EmptyFoldersRow()
            }
            ZStack {
                NavigationLink(
                    destination: AddNoteView(form: NoteForm(folders.count), audioRecorder: AudioRecorder()).environmentObject(store),
                    isActive: $addNote,
                    label: {
                        EmptyView()
                    }).isDetailLink(false)
                List {
                    ForEach(searchResult) { folder in
                        if editMode == .active {
                            MainListRow(data: folder)
                                .onTapGesture {
                                    selectedFolder = folder
                                    editFolder = true
                                }
                        } else {
                            NavigationLink(
                                destination: NotesView(storeManager: storeManager, folder: folder).environmentObject(store).environmentObject(noteManager),
                                label: {
                                    MainListRow(data: folder)

                                })
                                .isDetailLink(false)
                        }
                    }
                    .onDelete(perform: onDelete)
                    .onMove(perform: onMove)
                }
                .environment(\.editMode, $editMode)
                .listStyle(InsetGroupedListStyle())

                if storeManager.isLoading {
                    ActivityIndicatorView(isVisible: .constant(true), type: .default)
                        .frame(width: 36, height: 36)
                        .foregroundColor(toggleMaanger.isDark ? .white: .black)
                }

                if newFolder {
                    AlertControlView(form: FolderForm(index: folders.count),
                                     showAlert: $newFolder,
                                     title: "New Folder",
                                     message: "")
                        .environmentObject(store)

                }

                if editFolder {
                    AlertControlView(form: FolderForm(selectedFolder!),
                                     showAlert: $editFolder,
                                     title: "Edit Folder",
                                     message: "")
                        .environmentObject(store)
                }

            }

        }
        .navigationBarTitle("Folders")
        .navigationBarItems(
            leading: NavigationLink(
                destination: SettingsView(storeManager: storeManager).environmentObject(noteManager).environmentObject(toggleMaanger),
                label: {
                    Image(systemName: "gear")
                }),
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
                }, label: {
                    Text(editMode == .active ? "Done": "Edit")
                })
            }
            )
        .toolbar(content: {
            ToolbarItem(id: "", placement: .bottomBar) {
                newFolderButton
                    .environmentObject(store)
                    .frame(width: appConstants.bottomButtonSize, height: appConstants.bottomButtonSize)
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(id: "", placement: .bottomBar) {
                Button(action: {
                    if store.getNotesCount() < 10 || noteManager.getPurchased() {
                        withAnimation { addNote.toggle() }
                    } else {
                        withAnimation { showPurchase.toggle() }
                    }
                }, label: {
                    Image(systemName: "square.and.pencil")
                        .resizable().aspectRatio(contentMode: .fit)
                }).frame(width: appConstants.bottomButtonSize, height: appConstants.bottomButtonSize).padding()
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
    }
    
    var newFolderButton: some View {
        Button(action: openNewFolder) {
            Image(systemName: "folder.badge.plus")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .background(Color.clear)
        }
        .background(Color.clear)
    }

    func openNewFolder() {
        if store.getNotesCount() < 10 || noteManager.getPurchased() {
            withAnimation { newFolder.toggle() }
        } else {
            withAnimation { showPurchase.toggle() }
        }
    }

    private func onDelete(at offsets: IndexSet) {
        // preserve all ids to be deleted to avoid indices confusing
        let idsToDelete = offsets.map { self.folders[$0].id }
        if idsToDelete.count > 0 {
            store.delete(folderId: idsToDelete.first!)
        }
    }
    
    private func onMove(source: IndexSet, destination: Int) {
        var temp = folders
        temp.move(fromOffsets: source, toOffset: destination)
        for i in 0..<temp.count {
            store.update(folderId: temp[i].id, title: temp[i].title, count: temp[i].count, index: i)
        }
    }
}

struct EmptyFoldersRow: View {
    var body: some View {
        Section {
            HStack {
                Spacer()
                Text("Add some folder to the list ")
                Image(systemName: "folder.badge.plus")
                Spacer()
            }
              .foregroundColor(.gray)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    @EnvironmentObject var store: NoteStore

    @State private var editMode = EditMode.inactive
    let folders: [Folder]
    static var previews: some View {
        MainView(storeManager: StoreManager(), folders: [])
    }
}

struct CustomAlert: View {
    @EnvironmentObject var store: NoteStore
    @ObservedObject var form: FolderForm
    @Binding var showingAlert: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
            VStack {
                Text("New Folder")
                    .font(.title)
                    .foregroundColor(.black)
                
                Divider()
                
                TextField("Folder", text: $form.title)
                    .padding(5)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                
                Divider()
                
                HStack {
                    Button("Cancel") {
                        self.showingAlert.toggle()
                    }
                }
                .padding(30)
                .padding(.horizontal, 40)
            }
        }
        .frame(width: 300, height: 200)
    }
}
