import SwiftUI
import UniformTypeIdentifiers
import Messages
import MessageUI
struct SelectFolderView: View {
    @EnvironmentObject var store: NoteStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var editMode = EditMode.inactive
    let folders: [Folder]
    @State var search = ""
    @State var selectedFolder: [Folder] = []
    @State var selectAll: Bool = false
    @State var isExporting: Bool = false
    @State var showSelector: Bool = false
    @State var isEmail: Bool = false
    @State private var document: MessageDocument?
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var message: String = ""

    var body: some View {
        ZStack {
            List {
                if !folders.isEmpty {
                    SearchBar(text: $search)
                }
                ForEach(folders, id: \.id) { folder in
                    SelectionRow(folder: folder, isSelected: self.selectedFolder.contains(where: { (f) -> Bool in
                        f.id == folder.id
                    })) {
                        if self.selectedFolder.contains(where: { (f) -> Bool in
                            f.id == folder.id
                        }) {
                            self.selectedFolder.removeAll { (f) -> Bool in
                                f.id == folder.id
                            }
                        }
                        else {
                            self.selectedFolder.append(folder)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationBarTitle("Select Folders")
        .edgesIgnoringSafeArea(.all)
        .navigationBarItems(
            trailing: Button(action: {
                showSelector.toggle()
            }, label: {
                Text("Export")
                    .disabled(selectedFolder.count == 0)
            })
            )
        .toolbar(content: {

            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            ToolbarItem(id: "", placement: .bottomBar) {
                Button(action: {
                    self.selectedFolder = self.folders
                }, label: {
                    Text("Select All").foregroundColor(Color.black)
                }).padding()
            }
        })
        .fileExporter(
            isPresented: $isExporting,
            document: document,
            contentType: UTType.plainText,
            defaultFilename: "Notes"
        ) { result in
            if case .success = result {
                // Handle success.
            } else {
                // Handle failure.
            }
        }
        .actionSheet(isPresented: $showSelector, content: {
            ActionSheet(title: Text("Select your option"), message: nil, buttons: [
                .default(Text("To File"), action: {
                    message = ""
                    for f in self.selectedFolder {
                        if message != "" {
                            message.append("\n")
                        }
                        message.append(f.getNoteText())
                    }

                    document = MessageDocument(message: message)
                    isExporting = true
                }),
                .default(Text("To Email"), action: {
                    message = ""
                    for f in self.selectedFolder {
                        if message != "" {
                            message.append("\n")
                        }
                        message.append(f.getNoteText())
                    }

                    isEmail = true
                }),
                .cancel()
            ])
        })
        .sheet(isPresented: $isEmail) {
            MailView(isShowing: self.$isEmail, message: message, result: self.$result)
        }

    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }

}
 
struct SelectFolderView_Previews: PreviewProvider {
    @EnvironmentObject var store: NoteStore

    @State private var editMode = EditMode.inactive
    let folders: [Folder]
    static var previews: some View {
        SelectFolderView(folders: [])
    }
}

struct MessageDocument: FileDocument {
    
    static var readableContentTypes: [UTType] { [.plainText] }

    var message: String

    init(message: String) {
        self.message = message
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        message = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: message.data(using: .utf8)!)
    }
    
}
