
import Foundation
import RealmSwift

enum RealmMigrator {
  static private func migrationBlock(
    migration: Migration,
    oldSchemaVersion: UInt64
  ) {
    if oldSchemaVersion < 2 {
      migration.enumerateObjects(ofType: FolderDB.className()) { _, newObject in
//        newObject?["title"] = "New Folder"
      }
    }
  }

  static func setDefaultConfiguration() {
    let config = Realm.Configuration(
      schemaVersion: 2,
      migrationBlock: migrationBlock)
    Realm.Configuration.defaultConfiguration = config
  }
}
