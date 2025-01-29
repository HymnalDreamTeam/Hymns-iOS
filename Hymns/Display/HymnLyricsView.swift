import MobileCoreServices
import Prefire
import SwiftUI
import UniformTypeIdentifiers

public struct HymnLyricsView: View {

    @ObservedObject private var viewModel: HymnLyricsViewModel
    @State private var width: CGFloat?

    init(viewModel: HymnLyricsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if viewModel.showTransliterationButton {
                HStack {
                    Spacer()
                    Button(action: {
                        self.viewModel.transliterate.toggle()
                    }, label: {
                        self.viewModel.transliterate ?
                        Image(systemName: "a.square.fill").accessibilityLabel(Text("Transliteration on. Click to toggle.", comment: "A11y label for button toggling transliteration off.")).accentColor(.accentColor) :
                        Image(systemName: "a.square").accessibilityLabel(Text("Transliteration off. Click to toggle.", comment: "A11y label for button toggling transliteration on.")).accentColor(.primary)
                    }).frame(width: 25, height: 25)
                }
            }
            SelectableText(viewModel.lyrics, width: $width)
        }
        .preference(key: DisplayHymnView.DisplayTypeKey.self, value: .lyrics)
        .overlay(
            GeometryReader { reader in
                Color.clear.frame(height: 0)
                    .preference(key: WidthKey.self, value: reader.size.width)
            }
        ).onPreferenceChange(WidthKey.self) { width in
            self.width = width
        }.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).padding()
        // Need additional padding on the bottom to allow room for the view to clear the bottom bar. Otherwise, the bottom bar
        // will cover the bottom of the lyrics content with no way to show it.
        .padding(.bottom, 150)
        .background(Color(.systemBackground))
    }

    struct WidthKey: PreferenceKey {
        static let defaultValue: CGFloat? = nil
        static func reduce(value: inout CGFloat?,
                           nextValue: () -> CGFloat?) {
            value = value ?? nextValue()
        }
    }
}

#if DEBUG
struct HymnLyricsView_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {
        let classic40ViewModel = HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn40,
                                                     lyrics: classic40_preview.lyrics.verses)!
        let classic40 = HymnLyricsView(viewModel: classic40ViewModel)

        let classic1151ViewModel = HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1151,
                                                       lyrics: classic1151_preview.lyrics.verses)!
        let classic1151 = HymnLyricsView(viewModel: classic1151ViewModel)

        let classic1334ViewModel = HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.hymn1334,
                                                       lyrics: classic1334_preview.lyrics.verses)!
        let classic1334 = HymnLyricsView(viewModel: classic1334ViewModel)

        let chineseSupplement216ViewModel = HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.chineseSupplement216,
                                                                lyrics: chineseSupplement216_preview.lyrics.verses)!
        chineseSupplement216ViewModel.showTransliterationButton = true
        let chineseSupplement216 = HymnLyricsView(viewModel: chineseSupplement216ViewModel)

        let transliterateViewModel = HymnLyricsViewModel(hymnToDisplay: PreviewHymnIdentifiers.chineseSupplement216,
                                                         lyrics: chineseSupplement216_preview.lyrics.verses)!
        transliterateViewModel.showTransliterationButton = true
        transliterateViewModel.transliterate = true
        let transliterate = HymnLyricsView(viewModel: transliterateViewModel)

        return Group {
            ScrollView {
                classic40
            }.previewDisplayName("classic40")
            ScrollView {
                classic1151
            }.previewDisplayName("classic1151")
            ScrollView {
                classic1334
            }.previewDisplayName("classic1334")
            ScrollView {
                chineseSupplement216}
            .previewDisplayName("chineseSupplement216")
            ScrollView {
                transliterate}
            .previewDisplayName("transliterate").snapshot(delay: 0.1)
        }
    }
}
#endif
