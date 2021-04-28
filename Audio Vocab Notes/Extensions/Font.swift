//
//  Font.swift
//  Vocabulary Audio Notes
//
//  Created by welcome on 1/6/21.
//
import UIKit
import SwiftUI

enum Family: String {
    case system = ".SFUIText" //".SFUI"
    case inter = "Inter"

    //easy to change default app fonts family
    static let defaultFamily = Family.inter
}

enum CustomWeight: String {
    case regular = "", medium, light, heavy, bold, semibold, black
}

enum Size: CGFloat {
    case h1 = 36, h2 = 28, h3 = 20
    case bodyL = 17, bodyM = 15, bodyS = 13
}

//MARK: - Font Parts
public extension UIFont {


    //put Family and Weight together
    private class func stringName(_ family: Family, _ weight: CustomWeight) -> String {
        /**
        Define incompatible family, weight here
        in this case set defaults compatible values
        */
        let fontWeight: String
        switch (family, weight) {
        case (.inter, .heavy): fontWeight = CustomWeight.semibold.rawValue
        case (.inter, .light): fontWeight = "\(weight.rawValue)BETA"
        default:               fontWeight = weight.rawValue
        }
        let familyName = family.rawValue
        return fontWeight.isEmpty ? "\(familyName)" : "\(familyName)-\(fontWeight)"
    }
}

//MARK: - Initializers
extension UIFont {
    
    convenience init(_ size: Size, _ weight: CustomWeight) {
        self.init(.defaultFamily, size, weight)
    }
    
    convenience init(_ family: Family = .defaultFamily,
                     _ size: Size, _ weight: CustomWeight) {
        self.init(name: Self.stringName(family, weight), size: size.rawValue)!
    }
}

//MARK: - SwiftUI
@available(iOS 13.0, *)
extension Font {
    
    init(_ size: Size, _ weight: CustomWeight) {
        self.init(.defaultFamily, size, weight)
    }

    init(_ family: Family = .defaultFamily,
                     _ size: Size, _ weight: CustomWeight) {
        self.init(UIFont(family, size, weight))
    }
}
