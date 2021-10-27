import SwiftUI

extension ContentSizeCategory {

    func isAccessibilityCategory() -> Bool {
        let a11ySizes: [ContentSizeCategory] = [.accessibilityMedium, .accessibilityLarge, .accessibilityExtraLarge,
                                                .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge]
        return a11ySizes.contains(self)
    }
}
