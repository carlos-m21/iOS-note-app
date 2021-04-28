import SwiftUI
import StoreKit
struct ContentView: View {
    @EnvironmentObject var store: NoteStore
    @EnvironmentObject var noteManager: NoteCountManager
    @EnvironmentObject var toggleMaanger: ToggleModel
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var storeManager: StoreManager
    let productIDs = [
        "com.ios.audionote.premium"
    ]

    var body: some View {
        NavigationView {
            MainView(storeManager: storeManager, folders: store.folders)
                .environmentObject(store)
                .environmentObject(noteManager)
                .environmentObject(toggleMaanger)
                .environmentObject(fontManager)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: { [self] in
            SKPaymentQueue.default().add(storeManager)
            storeManager.getProducts(productIDs: productIDs)
            fontManager.getFont()
        })

    }
    
}
