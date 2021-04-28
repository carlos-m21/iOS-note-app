import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

//        MyThemes.restoreLastTheme()
//        UIApplication.shared.theme_setStatusBarStyle([.lightContent, .default, .lightContent, .lightContent], animated: true)
        
        // navigation bar

//        let navigationBar = UINavigationBar.appearance()
        
//        let shadow = NSShadow()
//        shadow.shadowOffset = CGSize(width: 0, height: 0)
//
//        let titleAttributes = GlobalPicker.barTextColors.map { hexString in
//            return [
//                NSAttributedString.Key.foregroundColor: UIColor(rgba: hexString),
//                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18),
//                NSAttributedString.Key.shadow: shadow
//            ]
//        }
//
//        let largeLitleAttributes = GlobalPicker.barTextColors.map { hexString in
//            return [
//                NSAttributedString.Key.foregroundColor: UIColor(rgba: hexString),
//                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 32),
//                NSAttributedString.Key.shadow: shadow
//            ]
//        }
        
//        navigationBar.theme_tintColor = GlobalPicker.barTextColor
//        navigationBar.theme_barTintColor = GlobalPicker.barTintColor
//
//        let coloredAppearance = UINavigationBarAppearance()
//        coloredAppearance.configureWithDefaultBackground()
//        coloredAppearance.theme_backgroundColor = GlobalPicker.barTintColor
//        coloredAppearance.theme_titleTextAttributes = ThemeStringAttributesPicker.pickerWithAttributes(titleAttributes)
//        coloredAppearance.theme_largeTitleTextAttributes = ThemeStringAttributesPicker.pickerWithAttributes(largeLitleAttributes)
//        navigationBar.theme_standardAppearance = ThemeNavigationBarAppearancePicker(appearances: coloredAppearance)
//        navigationBar.theme_compactAppearance = ThemeNavigationBarAppearancePicker(appearances: coloredAppearance)
//        navigationBar.theme_scrollEdgeAppearance = ThemeNavigationBarAppearancePicker(appearances: coloredAppearance)
//
//        navigationBar.theme_titleTextAttributes = ThemeStringAttributesPicker.pickerWithAttributes(titleAttributes)
//
//        // tab bar
//
//        let tabBar = UITabBar.appearance()
//
//        tabBar.theme_tintColor = GlobalPicker.barTextColor
//        tabBar.theme_barTintColor = GlobalPicker.barTintColor

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

