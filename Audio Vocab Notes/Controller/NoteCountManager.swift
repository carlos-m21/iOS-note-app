//
//  SecureKey.swift
//  Vocabulary Audio Notes
//
//  Created by welcome on 12/24/20.
//

import KeychainSwift
import Foundation
import CryptoKit
import Combine
import SwiftUI
struct SecureKey {
    static let purchased = "com.ios.audionote.purchase"
    static let noteCount = "com.ios.audionote.notecount"
}
class NoteCountManager: ObservableObject {
    
    @Published var noteCount: Int = 0
    @Published var purchased: Bool = false
    
    public static let shared = NoteCountManager()
    private var cancellableSet: Set<AnyCancellable> = []

    private var keychain = KeychainSwift()

    init() {
        _ = getNoteCount()
        _ = getPurchased()
        
        if UserDefaults.standard.object(forKey: "isFirst") == nil {
            self.setPurchased(false)
            UserDefaults.standard.set(true, forKey: "isFirst")
            UserDefaults.standard.synchronize()
        }
    }
    func getNoteCount() -> Int {
        if let countString = keychain.get(SecureKey.noteCount), let count = Int(countString) {
            noteCount = count
            return noteCount
        } else {
            noteCount = 0
            return noteCount
        }
    }
    
    func getPurchased() -> Bool{
        if let purchased = keychain.getBool(SecureKey.purchased) {
            self.purchased = purchased
            return purchased
        } else {
            self.purchased = false
            return purchased
        }
    }
    
    func setCount()  {
        self.noteCount = noteCount + 1
        keychain.set("\(self.noteCount)", forKey: SecureKey.noteCount,withAccess: .accessibleWhenUnlocked)
    }

    func setPurchased(_ isPurchase: Bool) {
        self.purchased = isPurchase
        keychain.set(self.purchased, forKey: SecureKey.purchased,withAccess: .accessibleWhenUnlocked)
    }
      
}
