//Created for Audio Vocab Notes  (31.10.2020 )

import SwiftUI
import Foundation
import CoreGraphics

let purchaseDescription = "You are limited to 10 notes. Please purchase to unlock the unlimited version"
struct appConstants {
    static let bottomButtonSize: CGFloat = 22
}
class Matrix {
    static let headerPrimarySize: CGFloat = 36
    static let headerSecondarySize: CGFloat = 27
    static let paragraphSize: CGFloat = 18
    static let stackViewSpacing: CGFloat = 20
    static let cornerRadius: CGFloat = 12
}

struct PrimaryHeader: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: Matrix.headerPrimarySize,
                              weight: .bold,
                              design: .default))
            .foregroundColor(Color.textHeaderPrimary)
    }
}

extension View {
    func primaryHeader() -> some View {
         return self.modifier(PrimaryHeader())
    }
}

struct SecondaryHeader: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: Matrix.headerSecondarySize,
                              weight: .semibold,
                              design: .default))
            .foregroundColor(Color.textHeaderPrimary)
    }
}

extension View {
    func secondaryHeader() -> some View {
         return self.modifier(SecondaryHeader())
    }
}


struct Paragraph: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: Matrix.paragraphSize,
                              weight: .regular,
                              design: .default))
            .foregroundColor(Color.textHeaderPrimary)
    }
}

extension View {
    func paragraph() -> some View {
         return self.modifier(Paragraph())
    }
}

public struct PrimaryButton: ViewModifier {
    public func body(content: Content) -> some View {
        content.foregroundColor(Color.theme)
        .padding()
        .font(Font.system(size: Matrix.paragraphSize,
                        weight: .semibold,
                        design: .default))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.theme, lineWidth: 1)
        )
            
    }
}

extension View {
    public func primaryButton() -> some View {
        self.modifier(PrimaryButton())
    }
}


public struct SecondaryButton: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .foregroundColor(Color.solidButtontext)
            .padding() //can add custom padding with matrix class
            .font(Font.system(size: Matrix.paragraphSize,
                            weight: .semibold,
                            design: .default))
            .background(Color.theme)
            .cornerRadius(Matrix.cornerRadius)
    }
}

extension View {
    public func secondaryButton() -> some View {
        self.modifier(SecondaryButton())
    }
}
