import UIKit
import SwiftUI
import RealmSwift
import EnvironmentOverrides
import StoreKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    @StateObject var storeManager = StoreManager()

    private(set) static var shared: SceneDelegate?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        updateAppearance()
        for fontFamily in UIFont.familyNames {
            print(fontFamily)
            for fontName in UIFont.fontNames(forFamilyName: fontFamily) {
                print("------- \(fontName)")
            }
        }

        RealmMigrator.setDefaultConfiguration()
        if let windowScene = scene as? UIWindowScene {
          do {
            // 1
            let realm = try Realm()
            let window = UIWindow(windowScene: windowScene)
            Self.shared = self
            // 2
            let toggleMaanger = ToggleModel.shared
            let contentView = ContentView().accentColor(Color.theme)
                .environmentObject(storeManager)
                .environmentObject(NoteStore(realm: realm))
                .environmentObject(NoteCountManager())
                .environmentObject(toggleMaanger)
                .environmentObject(FontManager())

            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
          } catch let error {
            // Handle error
            fatalError("Failed to open Realm. Error: \(error.localizedDescription)")
          }
        }
        // Use a UIHostingController as window root view controller.
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    private func updateAppearance() {
        
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.textHeaderPrimary]

        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.textHeaderPrimary]
        UISwitch.appearance().onTintColor = UIColor.theme
        
        //set other like tableView etc
        
    }

}

