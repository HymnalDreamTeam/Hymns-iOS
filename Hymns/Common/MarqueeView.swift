import SwiftUI

struct MarqueeText: View {

    private let text: String
    private let autoReverse: Bool

    @State private var scrollTextNegativeOffset: CGFloat?

    init(_ text: String, autoReverse: Bool = false) {
        self.text = text
        self.autoReverse = autoReverse
    }

    var body : some View {
        // Create an empty view so we can use geometry reader without it taking up a bunch of vertical space
        Text("")
            .padding([.vertical, .trailing]).maxWidth(alignment: .leading)
            .background(GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(self.text)
                        .offset(x: self.scrollTextNegativeOffset ?? geometry.size.width)
                        .animation(Animation.linear(duration: 10).repeatForever(autoreverses: self.autoReverse))
                        .anchorPreference(key: MarqueeWidthPreferenceKey.self, value: .bounds) { anchor in
                            return geometry[anchor].width
                        }.maxHeight()
                }.onPreferenceChange(MarqueeWidthPreferenceKey.self) { width in
                    self.scrollTextNegativeOffset = -width
                }
            })
    }
}

/**
 * Preference key to keep track of the text's width.
 */
struct MarqueeWidthPreferenceKey: PreferenceKey {
    static var defaultValue = CGFloat.zero

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#if DEBUG
struct MarqueeText_Previews: PreviewProvider {
    static var previews: some View {
        let defaultState = MarqueeText("here is the marquee text")
        let autoReverse = MarqueeText("here is the marquee text", autoReverse: true)
        return
            Group {
                defaultState.previewDisplayName("default state")
                autoReverse.previewDisplayName("auto reverse")
            }.previewLayout(.fixed(width: 600, height: 200))
    }
}
#endif
