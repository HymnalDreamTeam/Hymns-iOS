import SwiftUI

@objc enum TagColor: Int {
    case none, blue, green, yellow, red

    static var allColors: [TagColor] {
        return [blue, green, yellow, red]
    }
}

extension TagColor {
    var name: String {
        switch self {
        case .none:
            return NSLocalizedString("None", comment: "Tag has no color.")
        case .blue:
            return NSLocalizedString("Blue", comment: "Tag color is blue.")
        case .green:
            return NSLocalizedString("Green", comment: "Tag color is green.")
        case .yellow:
            return NSLocalizedString("Yellow", comment: "Tag color is yellow.")
        case .red:
            return NSLocalizedString("Red", comment: "Tag color is red.")
        }
    }

    var background: Color {
        switch self {
        case .none:
            return Color(.systemBackground)
        case .blue:
            return Color(red: 2/255, green: 118/255, blue: 254/255, opacity: 0.2)
        case .green:
            return Color(red: 80/255, green: 227/255, blue: 194/255, opacity: 0.2)
        case .yellow:
            return Color(red: 255/255, green: 209/255, blue: 0/255, opacity: 0.2)
        case .red:
            return Color(red: 234/255, green: 77/255, blue: 133/255, opacity: 0.2)
        }
    }

    var foreground: Color {
        switch self {
        case .none:
            return Color.primary
        case .blue:
            return Color(red: 2/255, green: 118/255, blue: 254/255, opacity: 1.0)
        case .green:
            return Color(red: 35/255, green: 190/255, blue: 155/255, opacity: 1.0)
        case .yellow:
            return Color(red: 176/255, green: 146/255, blue: 7/255, opacity: 1.0)
        case .red:
            return Color(red: 234/255, green: 77/255, blue: 133/255, opacity: 1.0)
        }
    }
}

extension TagColor: Identifiable {
    var id: String { String(rawValue) }
}

extension TagColor: CustomStringConvertible {
    var description: String { name }
}
