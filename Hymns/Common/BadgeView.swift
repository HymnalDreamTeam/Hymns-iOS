import SwiftUI

struct BadgeModifier: ViewModifier {

    @Binding var shouldShow: Bool

    let badgeContent: AnyView
    let xOffset: CGFloat
    let yOffset: CGFloat

    init<Content: View>(badgeContent: Content, position: Alignment, shouldShow: Binding<Bool> ) {
        self.badgeContent = AnyView(badgeContent)
        self._shouldShow = shouldShow

        switch position {
        case .topTrailing:
            xOffset = 10
            yOffset = -10
        // Add other cases as we need them.
        default:
            xOffset = 0
            yOffset = 0
        }
    }

    func body(content: Content) -> some View {
        content.overlay {
            if shouldShow {
                badgeContent
                    .font(.caption)
                    .padding(6)
                    .foregroundColor(.white)
                    .background(.red)
                    .clipShape(Circle())
                    .offset(x: xOffset, y: yOffset)
            }
        }
    }
}
extension View {
    func badge<Content: View>(badgeContent: Content = Image("circle.fill"),
                              position: Alignment = .topTrailing,
                              shouldShow: Binding<Bool> = .constant(true)) -> some View {
        self.modifier(BadgeModifier(badgeContent: badgeContent, position: position, shouldShow: shouldShow))
    }
}
