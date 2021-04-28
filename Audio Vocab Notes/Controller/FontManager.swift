import Foundation
import SwiftUI
import Combine
class FontManager: ObservableObject {
    @Published var fontNames: [String] = []
    @Published var appfont: Font = Font.system(size: 14)
    @Published var appFontName: String = "" {
        didSet {
            UserDefaults.standard.set(appFontName, forKey: "appFont")
            UserDefaults.standard.synchronize()
            self.appfont = Font.custom(appFontName, size: fontSize)
        }
    }
    @Published var fontSize: CGFloat = 14 {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: "fontSize")
            UserDefaults.standard.synchronize()
            self.appfont = Font.custom(appFontName, size: fontSize)
        }
    }
    @Published var selectedFont: Int = 0 {
        didSet {
            appFontName = fontNames[selectedFont]
        }
    }

    public static let shared = FontManager()

    init() {
        
    }
    func getFont() {
        for fontFamily in UIFont.familyNames {
            for fontName in UIFont.fontNames(forFamilyName: fontFamily) {
                print("\(fontName)")
                fontNames.append(fontName)
            }
        }
        if UserDefaults.standard.object(forKey: "fontSize") == nil {
            fontSize = 14
        } else {
            fontSize = CGFloat(UserDefaults.standard.float(forKey: "fontSize"))
        }
        if UserDefaults.standard.object(forKey: "appFont") == nil {
            appfont = Font.system(size: fontSize)
        } else {
            if let name = UserDefaults.standard.string(forKey: "appFont") {
                appFontName = name
                appfont = Font.custom(name, size: fontSize)
            } else {
                appfont = Font.system(size: fontSize)
            }
        }
        
        if let index = self.fontNames.firstIndex(of: appFontName) {
            self.selectedFont = index
        }
    }
    
    func setFont(_ font: String, fontSize: CGFloat, index1: Int, index2: Int) {
        self.fontSize = fontSize
        self.appFontName = font
        self.appfont = Font.custom(font, size: fontSize)
        self.selectedFont = index2
        UserDefaults.standard.set(font, forKey: "appFont")
        UserDefaults.standard.set(fontSize, forKey: "fontSize")
        UserDefaults.standard.synchronize()
    }
}
