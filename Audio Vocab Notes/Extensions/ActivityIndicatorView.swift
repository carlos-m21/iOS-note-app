//
//  ActivityIndicatorView.swift
//  Sound List
//
//  Created by welcome on 1/11/21.
//

import SwiftUI

public struct ActivityIndicatorView: View {

    public enum IndicatorType {
        case `default`
        case arcs
        case rotatingDots
        case flickeringDots
        case scalingDots
        case opacityDots
        case equalizer
        case growingArc(Color = .red)
        case growingCircle
        case gradient([Color], CGLineCap = .butt)
    }

    @Binding var isVisible: Bool
    var type: IndicatorType

    public init(isVisible: Binding<Bool>, type: IndicatorType) {
        self._isVisible = isVisible
        self.type = type
    }

    public var body: some View {
        guard isVisible else { return AnyView(EmptyView()) }
        switch type {
        case .default:
            return AnyView(DefaultIndicatorView())
        case .arcs:
            return AnyView(DefaultIndicatorView())
        case .rotatingDots:
            return AnyView(DefaultIndicatorView())
        case .flickeringDots:
            return AnyView(DefaultIndicatorView())
        case .scalingDots:
            return AnyView(DefaultIndicatorView())
        case .opacityDots:
            return AnyView(DefaultIndicatorView())
        case .equalizer:
            return AnyView(DefaultIndicatorView())
        case .growingArc(let color):
            return AnyView(DefaultIndicatorView())
        case .growingCircle:
            return AnyView(DefaultIndicatorView())
        case .gradient(let colors, let lineCap):
            return AnyView(DefaultIndicatorView())
        }
    }
}

struct DefaultIndicatorView: View {

    private let count: Int = 8

    public var body: some View {
        GeometryReader { geometry in
            ForEach(0..<self.count) { index in
                DefaultIndicatorItemView(index: index, count: self.count, size: geometry.size)
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct DefaultIndicatorItemView: View {

    let index: Int
    let count: Int
    let size: CGSize

    @State private var opacity: Double = 0

    var body: some View {
        let height = size.height / 3.2
        let width = height / 2
        let angle = 2 * .pi / CGFloat(count) * CGFloat(index)
        let x = (size.width / 2 - height / 2) * cos(angle)
        let y = (size.height / 2 - height / 2) * sin(angle)

        let animation = Animation.default
            .repeatForever(autoreverses: true)
            .delay(Double(index) / Double(count) / 2)

        return RoundedRectangle(cornerRadius: width / 2 + 1)
            .frame(width: width, height: height)
            .rotationEffect(Angle(radians: Double(angle + CGFloat.pi / 2)))
            .offset(x: x, y: y)
            .opacity(opacity)
            .onAppear {
                self.opacity = 1
                withAnimation(animation) {
                    self.opacity = 0.3
                }
            }
    }
}
