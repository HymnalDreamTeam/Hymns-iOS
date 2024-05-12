import MobileCoreServices
import SwiftUI
import UniformTypeIdentifiers

public struct HymnLyricsView: View {
    
    @ObservedObject private var viewModel: HymnLyricsViewModel
    @State private var contentHeight: CGFloat?

    init(viewModel: HymnLyricsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if viewModel.showTransliterationButton {
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.transliterate.toggle()
                    }, label: {
                        viewModel.transliterate ?
                        Image(systemName: "a.square.fill").accessibilityLabel(Text("Transliteration on. Click to toggle.", comment: "A11y label for button toggling transliteration off.")).accentColor(.accentColor) :
                        Image(systemName: "a.square").accessibilityLabel(Text("Transliteration off. Click to toggle.", comment: "A11y label for button toggling transliteration on.")).accentColor(.primary)
                    }).frame(width: 25, height: 25)
                }
            }
            SelectableText(viewModel.lyricsString).frame(height: contentHeight)
        }.onPreferenceChange(DisplayContentHeight.self, perform: { height in
            self.contentHeight = height
        })
        .preference(key: DisplayHymnView.DisplayTypeKey.self, value: .lyrics)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).padding([.top])
        // Need additional padding on the bottom to allow room for the view to clear the bottom bar. Otherwise, the
        // bottom bar will cover the bottom of the lyrics content with no way to show it.
        .padding(.bottom, 150)
        .background(Color(.systemBackground))
    }

    struct DisplayContentHeight: PreferenceKey {
        static let defaultValue: CGFloat? = nil
        static func reduce(value: inout CGFloat?,
                           nextValue: () -> CGFloat?) {
            value = nextValue()
        }
    }
}

#if DEBUG
struct HymnLyricsView_Previews: PreviewProvider {
    static var previews: some View {
        let classic40ViewModel = HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn40,
                                                     lyrics: classic40_preview.lyrics)!
        let classic40 = HymnLyricsView(viewModel: classic40ViewModel)

        let classic1151ViewModel = HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151,
                                                       lyrics: classic1151_preview.lyrics)!
        let classic1151 = HymnLyricsView(viewModel: classic1151ViewModel)

        let classic1334ViewModel = HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1334,
                                                       lyrics: classic1334_preview.lyrics)!
        let classic1334 = HymnLyricsView(viewModel: classic1334ViewModel)

        let chineseSupplement216ViewModel = HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.chineseSupplement216,
                                                                lyrics: chineseSupplement216_preview.lyrics)!
        chineseSupplement216ViewModel.showTransliterationButton = true
        let chineseSupplement216 = HymnLyricsView(viewModel: chineseSupplement216ViewModel)

        return Group {
            classic40.previewDisplayName("classic40")
            classic1151.previewDisplayName("classic1151")
            classic1334.previewDisplayName("classic1334")
            chineseSupplement216.previewDisplayName("chineseSupplement216")
        }
    }
}
#endif
