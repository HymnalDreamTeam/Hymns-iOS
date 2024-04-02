import Foundation

struct UiTag {

    let title: String
    let color: TagColor
}

extension UiTag: Hashable {
    static func == (lhs: UiTag, rhs: UiTag) -> Bool {
        lhs.title == rhs.title && lhs.color == rhs.color
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(color)
    }
}

extension UiTag: Identifiable {
    var id: String {
        "\(title):\(color.rawValue)"
    }
}
