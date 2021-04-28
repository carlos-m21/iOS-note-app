import Foundation
import RealmSwift
struct Note: Identifiable {
    var id: Int
    var title: String
    var text: String
    var file: String
    var folder: Int
    var index: Int
}

// MARK: Convenience init
extension Note {
    init(note: NoteDB) {
        id = note.id
        title = note.title
        text = note.text
        file = note.file
        folder = note.folder
        index = note.index
    }
}


class NoteDB: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    @objc dynamic var text = ""
    @objc dynamic var file = ""
    @objc dynamic var folder = 0
    @objc dynamic var index = 0

    override static func primaryKey() -> String? {
        "id"
    }
}

class NoteForm: ObservableObject {
    var id: Int?
    @Published var title = ""
    @Published var text = ""
    @Published var file: String = ""
    @Published var folder: Int = 0
    @Published var index: Int = 0

    var updating: Bool {
      id != nil
    }

    init(f: Folder, index: Int) {
        self.folder = f.id
        self.index = index
    }

    init(_ index: Int) {
        self.index = index
    }

    init(_ note: Note, index: Int) {
        title = note.title
        text = note.text
        file = note.file
        id = note.id
        folder = note.folder
        self.index = index
    }

    init(_ note: Note) {
        title = note.title
        text = note.text
        file = note.file
        id = note.id
        folder = note.folder
        index = note.index
    }
}

class FolderForm: ObservableObject {
    @Published var title = ""
    @Published var count = 0
    @Published var index = 1

    var id: Int?

    var updating: Bool {
        id != nil
    }

    init(index: Int) {
        self.index = index
    }

    init(_ folder: Folder) {
        title = folder.title
        count = folder.count
        index = folder.index
        id = folder.id
    }
}
