import Foundation
import SwiftUI

enum HymnTab {
    case lyrics(AnyView)
    case music(AnyView)
}

extension HymnTab {
    var label: String {
        switch self {
        case .lyrics:
            return NSLocalizedString("Lyrics", comment: "Tab to display a hymn's lyrics.")
        case .music:
            return NSLocalizedString("Music", comment: "Tab to display a hymn's sheet music.")
        }
    }
}

extension HymnTab: TabItem {

    var id: String { self.label }

    var content: AnyView {
        switch self {
        case .lyrics(let content):
            return content
        case .music(let content):
            return content
        }
    }

    var selectedLabel: some View {
        Text(label).font(.body).foregroundColor(.accentColor)
    }

    var unselectedLabel: some View {
        Text(label).font(.body).foregroundColor(.primary)
    }

    var a11yLabel: Text {
        Text(label)
    }

    static func == (lhs: HymnTab, rhs: HymnTab) -> Bool {
        lhs.id == rhs.id
    }
}
