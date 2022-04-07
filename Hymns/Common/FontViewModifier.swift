import SwiftUI

/// The custom title view modifier is meant to be set up to replace navigationBarTitle texts. By doing this, we gain the ability to customize the title text at the top of the screen. In addition,
/// we also avoid being forced into using navigation bar titles which comes with other issues as well.
struct CustomTitleLayout: ViewModifier {
    let font = Font.title.weight(.bold)
    func body(content: Content) -> some View {
        content
            .padding()
            .font(font)
    }
}

extension View {
    func customTitleLayout() -> some View {
        return self.modifier(CustomTitleLayout())
    }
}

/// https://useyourloaf.com/blog/scaling-custom-swiftui-fonts-with-dynamic-type/
struct ScaledFont: ViewModifier {

    private let font: Font

    init(_ fontSize: CGFloat) {
        self.font = .custom("Default", size: fontSize)
    }

    func body(content: Content) -> some View {
        content.font(font)
    }
}

extension View {
    func relativeFont(_ fontSize: CGFloat) -> some View {
        return self.modifier(ScaledFont(fontSize))
    }
}
