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
}

extension HymnMusicTab {

    var label: Image {
        switch self {
        case .piano:
            return Image(systemName: "pianokeys.inverse")
        case .guitar:
            return Image(systemName: "guitars.fill")
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
        }
    }

    var selectedLabel: some View {
        Text(label).font(.body).foregroundColor(.accentColor)
    }

    var unselectedLabel: some View {
        Text(label).font(.body).foregroundColor(.primary)
    }

    var a11yLabel: Text {
        switch self {
        case .piano:
            return Text("Piano sheet music", comment: "A11y label for showing the piano sheet music of a hymn.")
        case .guitar:
            return Text("Guitar chords", comment: "A11y label for showing the guitar chords of a hymn.")
        }
    }

    static func == (lhs: HymnMusicTab, rhs: HymnMusicTab) -> Bool {
        lhs.id == rhs.id
    }
}
