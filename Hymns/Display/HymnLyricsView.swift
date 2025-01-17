import MobileCoreServices
import Prefire
import SwiftUI
import UniformTypeIdentifiers

public struct HymnLyricsView: View {

    @ObservedObject private var viewModel: HymnLyricsViewModel
    @State private var transliterate = false
    @State private var toast: HymnLyricsToast?

    init(viewModel: HymnLyricsViewModel) {
        self.viewModel = viewModel
    }
    public var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if viewModel.showTransliterationButton {
                HStack {
                    Spacer()
                    Button(action: {
                        self.transliterate.toggle()
                    }, label: {
                        self.transliterate ?
                        Image(systemName: "a.square.fill").accessibilityLabel(Text("Transliteration on. Click to toggle.", comment: "A11y label for button toggling transliteration off.")).accentColor(.accentColor) :
                        Image(systemName: "a.square").accessibilityLabel(Text("Transliteration off. Click to toggle.", comment: "A11y label for button toggling transliteration on.")).accentColor(.primary)
                    }).frame(width: 25, height: 25)
                }
            }
            ForEach(viewModel.lyrics, id: \.self) { verseViewModel in
                VerseView(viewModel: verseViewModel, transliterate: self.$transliterate)
                    .onTapGesture {
                        // needed so onLongPressGesture doesn't hijack the tap and make the view unscrollabe
                        // https://stackoverflow.com/a/60015111/1907538
                    }.onLongPressGesture {
                        UIPasteboard.general.setValue(
                            verseViewModel.createFormattedString(includeTransliteration: self.transliterate),
                            forPasteboardType: UTType.plainText.identifier)
                        self.toast = .verseCopied
                    }
            }
        }
        .preference(key: DisplayHymnView.DisplayTypeKey.self, value: .lyrics)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).padding()
        // Need additional padding on the bottom to allow room for the view to clear the bottom bar. Otherwise, the bottom bar
        // will cover the bottom of the lyrics content with no way to show it.
        .padding(.bottom, 150)
        .toast(item: $toast, options: ToastOptions(alignment: .bottom, disappearAfter: 2)) { toastType -> AnyView in
            switch toastType {
            case .verseCopied:
                return HStack {
                    Image(systemName: "checkmark").foregroundColor(.green).padding()
                    Text("Verse copied to clipboard", comment: "Toast message when a verse has been copied to the clipboard.").padding(.trailing)
                }.eraseToAnyView()
            }
        }.background(Color(.systemBackground))
    }
}

enum HymnLyricsToast: Identifiable {
    var id: HymnLyricsToast { self }

    case verseCopied
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
        }
    }
}
#endif
