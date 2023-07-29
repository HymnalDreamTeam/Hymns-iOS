import SwiftUI

class HymnMusicViewModel: ObservableObject {

    @Published var currentTab: HymnMusicTab
    @Published var musicViews: [HymnMusicTab]

    init(musicViews: [HymnMusicTab]) {
        self.musicViews = musicViews
        guard let firstTab = musicViews.first else {
            self.currentTab = .piano(ErrorView().eraseToAnyView())
            return
        }
        self.currentTab = firstTab
    }
}

enum HymnMusicTab {
    case piano(AnyView)
    case guitar(AnyView)
    case inline(AnyView)
}

extension HymnMusicTab {

    var label: Image {
        switch self {
        case .piano:
            return Image(systemName: "pianokeys")
        case .guitar:
            return Image("guitalele")
        case .inline:
            return Image("lyrics")
        }
    }
}

extension HymnMusicTab: TabItem {

    var id: String { String(describing: self) }

    var content: AnyView {
        switch self {
        case .piano(let content):
            return content
        case .guitar(let content):
            return content
        case .inline(let content):
            return content
        }
    }

    var selectedLabel: some View {
        label.foregroundColor(.accentColor)
    }

    var unselectedLabel: some View {
        label.foregroundColor(.primary)
    }

    var a11yLabel: Text {
        switch self {
        case .piano:
            return Text("Piano sheet music", comment: "A11y label for showing the piano sheet music of a hymn.")
        case .guitar:
            return Text("Guitar sheet music", comment: "A11y label for showing the guitar sheet music of a hymn.")
        case .inline:
            return Text("Inline chords", comment: "A11y label for showing the inline chords of a hymn.")
        }
    }

    static func == (lhs: HymnMusicTab, rhs: HymnMusicTab) -> Bool {
        lhs.id == rhs.id
    }
}

#if DEBUG
struct HymnMusicTab_Previews: PreviewProvider {
    static var previews: some View {
        let guitar = HymnMusicTab.guitar(EmptyView().eraseToAnyView())
        let piano = HymnMusicTab.piano(EmptyView().eraseToAnyView())
        let inline = HymnMusicTab.inline(EmptyView().eraseToAnyView())
        return Group {
            inline.selectedLabel.previewDisplayName("inline selected")
            guitar.selectedLabel.previewDisplayName("guitar selected")
            piano.selectedLabel.previewDisplayName("piano selected")

            inline.unselectedLabel.previewDisplayName("inline unselected")
            guitar.unselectedLabel.previewDisplayName("guitar unselected")
            piano.unselectedLabel.previewDisplayName("piano unselected")
        }.previewLayout(.sizeThatFits)
    }
}
#endif
