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

#if DEBUG
struct HymnTab_Previews: PreviewProvider {
    static var previews: some View {
        var lyricsTab: HymnTab = .lyrics(Text("%_PREVIEW_% Lyrics here").eraseToAnyView())
        var musicTab: HymnTab = .music(Text("%_PREVIEW_% Music here").eraseToAnyView())

        let currentTabLyrics = Binding<HymnTab>(
            get: {lyricsTab},
            set: {lyricsTab = $0})

        let currentTabMusic = Binding<HymnTab>(
            get: {musicTab},
            set: {musicTab = $0})

        return Group {
            TabBar(currentTab: currentTabLyrics,
                   tabItems: [lyricsTab, musicTab],
                   tabSpacing: .maxWidth,
                   showIndicator: true).previewDisplayName("lyrics selected")
            TabBar(currentTab: currentTabMusic,
                   tabItems: [lyricsTab, musicTab],
                   tabSpacing: .maxWidth,
                   showIndicator: true).previewDisplayName("music selected")
            TabBar(currentTab: currentTabLyrics,
                   tabItems: [lyricsTab],
                   tabSpacing: .maxWidth,
                   showIndicator: true).previewDisplayName("only lyrics")
        }.previewLayout(.fixed(width: 450, height: 50))
    }
}
#endif
