import Foundation
import RealmSwift
struct Folder: Identifiable {
    var id: Int
    var title: String
    var index: Int
    var count: Int = 0
    
    private var fetchResults: Results<NoteDB>

    var notes: [Note] {
        fetchResults.map(Note.init)
    }

}

// MARK: Convenience init
extension Folder {

    init(folder: FolderDB, realm: Realm) {
        id = folder.id
        title = folder.title
        
        fetchResults = realm.objects(NoteDB.self).filter("folder = \(id)")
        index = folder.index
        count = folder.count
    }
    
    func getNoteText() -> String {
        var text = "Folder: "
        text.append(self.title)
        text.append("\n")
        text.append(" - Notes: ")
        for n in notes {
            text.append("\n\t - ")
            text.append(n.text)
        }
        return text
    }
}

class DataWrapper: Object {
    let list = List<FolderDB>()
}

class FolderDB: Object {
    let notes = List<NoteDB>()
    
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    @objc dynamic var index = 1
    @objc dynamic var count = 0

    override static func primaryKey() -> String? {
        "id"
    }
}
