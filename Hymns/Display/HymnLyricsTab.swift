import Foundation
import SwiftUI

enum HymnLyricsTab {
    case lyrics(AnyView)
    case chords(AnyView)
    case guitar(AnyView)
    case piano(AnyView)
}

extension HymnLyricsTab {

    var label: String {
        switch self {
        case .lyrics:
            return NSLocalizedString("Lyrics", comment: "Hymn lyrics tab.")
        case .chords:
            return NSLocalizedString("Chords", comment: "Hymn chords tab.")
        case .guitar:
            return NSLocalizedString("Guitar", comment: "Hymn guitar tab.")
        case .piano:
            return NSLocalizedString("Piano", comment: "Hymn piano tab.")
        }
    }
}

extension HymnLyricsTab: TabItem {

    var id: String { self.label }

    var content: AnyView {
        switch self {
        case .lyrics(let content):
            return content
        case .chords(let content):
            return content
        case .guitar(let content):
            return content
        case .piano(let content):
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

    static func == (lhs: HymnLyricsTab, rhs: HymnLyricsTab) -> Bool {
        lhs.label == rhs.label
    }
}

#if DEBUG
struct HymnLyricsTab_Previews: PreviewProvider {
    static var previews: some View {
        var lyricsTab: HymnLyricsTab = .lyrics(EmptyView().eraseToAnyView())
        var chordsTab: HymnLyricsTab = .chords(EmptyView().eraseToAnyView())
        var guitarTab: HymnLyricsTab = .guitar(EmptyView().eraseToAnyView())
        var pianoTab: HymnLyricsTab = .piano(EmptyView().eraseToAnyView())

        let currentTabLyrics = Binding<HymnLyricsTab>(
            get: {lyricsTab},
            set: {lyricsTab = $0})

        let currentTabChords = Binding<HymnLyricsTab>(
            get: {chordsTab},
            set: {chordsTab = $0})

        let currentTabGuitar = Binding<HymnLyricsTab>(
            get: {guitarTab},
            set: {guitarTab = $0})

        let currentTabPiano = Binding<HymnLyricsTab>(
            get: {pianoTab},
            set: {pianoTab = $0})

        return Group {
            GeometryReader { geometry in
                TabBar(currentTab: currentTabLyrics,
                       geometry: geometry,
                       tabItems: [lyricsTab, guitarTab, pianoTab])
            }.previewDisplayName("missing chords")
            GeometryReader { geometry in
                TabBar(currentTab: currentTabLyrics,
                       geometry: geometry,
                       tabItems: [lyricsTab, chordsTab, guitarTab, pianoTab])
            }.previewDisplayName("lyrics selected")
            GeometryReader { geometry in
                TabBar(currentTab: currentTabChords,
                       geometry: geometry,
                       tabItems: [lyricsTab, chordsTab, guitarTab, pianoTab])
            }.previewDisplayName("chords selected")
            GeometryReader { geometry in
                TabBar(currentTab: currentTabGuitar,
                       geometry: geometry,
                       tabItems: [lyricsTab, chordsTab, guitarTab, pianoTab])
            }.previewDisplayName("guitar selected")
            GeometryReader { geometry in
                TabBar(currentTab: currentTabPiano,
                       geometry: geometry,
                       tabItems: [lyricsTab, chordsTab, guitarTab, pianoTab])
            }.previewDisplayName("piano selected")
        }.previewLayout(.fixed(width: 450, height: 50))
    }
}
#endif
