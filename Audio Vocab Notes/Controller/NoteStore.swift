//
//  NoteStore.swift
//  Audio Vocab Notes
//
//  Created by welcome on 12/14/20.
//

import SwiftUI
import RealmSwift
final class NoteStore: ObservableObject {
    private var folderResults: Results<FolderDB>
    let realm: Realm
    
    public static let shared = NoteStore()

    init() {
        do {
            self.realm = try Realm()
            folderResults = realm.objects(FolderDB.self).sorted(byKeyPath: "index", ascending: true)
        } catch {
            print(error)
            fatalError("❌ Realm: Can't be Init()")
        }
    }
    
    init(realm: Realm) {
        self.realm = realm
        folderResults = realm.objects(FolderDB.self)
    }

    var folders: [Folder] {
        folderResults.map { fd in
            return Folder(folder: fd, realm: self.realm)
        }.sorted { (f1, f2) -> Bool in
            return f1.index < f2.index
        }
    }
}

// MARK: - CRUD Actions
extension NoteStore {
    
    func getNotesCount() -> Int {
        var count = 0
        for f in folders {
            count = count + f.count
        }
        return count
    }
    
    func create(title: String, index: Int) {
        objectWillChange.send()

        do {
            let realm = try Realm()

            let folderDB = FolderDB()
            folderDB.id = UUID().hashValue
            folderDB.title = title == "" ? "New Folder": title
            folderDB.count = 0
            folderDB.index = index

            try realm.write {
              realm.add(folderDB)
            }
        } catch let error {
          // Handle error
            print(error.localizedDescription)
        }
    }

    func addNote(note: NoteForm) {
        objectWillChange.send()
        if note.folder == 0 {
            if let folderDB = folderResults.first(where: {$0.title == "Notes" }) {
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.add(NoteDB(value: [
                            "id": UUID().hashValue,
                            "title": note.title,
                            "text": note.text.trimmingCharacters(in: .whitespacesAndNewlines),
                            "file": note.file,
                            "folder": folderDB.id
                        ]))
                    }
                    try realm.write {
                        realm.create(
                            FolderDB.self,
                            value: ["id": folderDB.id, "count": folderDB.count + 1],
                            update: .modified
                        )
                    }
                    NoteCountManager.shared.setCount()
                } catch let error {
                  // Handle error
                    print(error.localizedDescription)
                }
            } else {
                do {
                    let realm = try Realm()

                    let folderDB = FolderDB()
                    folderDB.id = UUID().hashValue
                    folderDB.title = "Notes"
                    folderDB.count = 0
                    folderDB.index = folderResults.count

                    try realm.write {
                      realm.add(folderDB)
                    }
                    
                    try realm.write {
                        realm.add(NoteDB(value: [
                            "id": UUID().hashValue,
                            "title": note.title,
                            "text": note.text.trimmingCharacters(in: .whitespacesAndNewlines),
                            "file": note.file,
                            "folder": folderDB.id
                        ]))
                    }
                    try realm.write {
                        realm.create(
                            FolderDB.self,
                            value: ["id": folderDB.id, "count": folderDB.count + 1],
                            update: .modified
                        )
                    }
                    NoteCountManager.shared.setCount()
                } catch let error {
                  // Handle error
                    print(error.localizedDescription)
                }
            }
        } else {
            guard let folderDB = folderResults.first(where: {$0.id == note.folder }) else {
                return
            }
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(NoteDB(value: [
                        "id": UUID().hashValue,
                        "title": note.title,
                        "text": note.text.trimmingCharacters(in: .whitespacesAndNewlines),
                        "file": note.file,
                        "folder": note.folder
                    ]))
                }
                try realm.write {
                    realm.create(
                        FolderDB.self,
                        value: ["id": folderDB.id, "count": folderDB.count + 1],
                        update: .modified
                    )
                }
                NoteCountManager.shared.setCount()
            } catch let error {
              // Handle error
                print(error.localizedDescription)
            }
        }
    }

    func update(
        folderId: Int,
        title: String,
        count: Int,
        index: Int
    ) {
        objectWillChange.send()
        do {
            let realm = try Realm()
            try realm.write {
                realm.create(
                    FolderDB.self,
                    value: [
                        "id": folderId,
                        "title": title,
                        "index": index,
                        "count": count
                    ],
                    update: .modified)
            }
        } catch let error {
          // Handle error
            print(error.localizedDescription)
        }
    }

    func updateNote(
        note: NoteForm
    ) {
        objectWillChange.send()
        guard folderResults.first(where: {$0.id == note.folder }) != nil else {
            return
        }
        do {
            let realm = try Realm()
            try realm.write {
                realm.create(
                    NoteDB.self,
                    value: [
                        "id": note.id as Any,
                        "title": note.title,
                        "text": note.text.trimmingCharacters(in: .whitespacesAndNewlines),
                        "file": note.file,
                        "folder": note.folder
                    ],
                    update: .modified)
            }
        } catch let error {
          // Handle error
            print(error.localizedDescription)
        }
    }

    func deleteAudio(
        note: NoteForm
    ) {
        objectWillChange.send()
        guard folderResults.first(where: {$0.id == note.folder }) != nil else {
            return
        }
        if note.file != "" {
            let fileManager = FileManager.default
            var filePath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            filePath.appendPathComponent(note.file)

            do {
               try FileManager.default.removeItem(at: filePath)
            } catch {
                print("File could not be deleted!")
            }
        }

        do {
            let realm = try Realm()
            try realm.write {
                realm.create(
                    NoteDB.self,
                    value: [
                        "id": note.id as Any,
                        "title": note.title,
                        "text": note.text.trimmingCharacters(in: .whitespacesAndNewlines),
                        "file": "",
                        "folder": note.folder
                    ],
                    update: .modified)
            }
        } catch let error {
          // Handle error
            print(error.localizedDescription)
        }
    }

    func delete(folderId: Int) {
        objectWillChange.send()
        
        guard let folderDB = folderResults.first(
                where: { $0.id == folderId })
        else { return }

        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(folderDB)
            }
        } catch let error {
          // Handle error
            print(error.localizedDescription)
        }
    }

    func deleteNote(note: Note) {
        objectWillChange.send()
        guard let folderDB = folderResults.first(where: {$0.id == note.folder }) else {
            return
        }
        let fetchResults = realm.objects(NoteDB.self).filter("folder = \(note.folder)")
        if let noteDB = fetchResults.first(where: { (db) -> Bool in
            db.id == note.id
        }) {
            do {
                let realm = try Realm()
                try realm.write {
                    realm.delete(noteDB)
                }
                try realm.write {
                    realm.create(
                        FolderDB.self,
                        value: ["id": folderDB.id, "count": folderDB.count - 1],
                        update: .modified
                    )
                }

            } catch let error {
              // Handle error
                print(error.localizedDescription)
            }
        }

    }
}
