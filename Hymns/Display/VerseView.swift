import Prefire
import Resolver
import SwiftUI

struct VerseLineView: View {

    @ObservedObject var viewModel: VerseLineViewModel
    @Binding var transliterate: Bool

    var body: some View {
        VStack(alignment: .leading) {
            viewModel.verseNumber.map { verseNumber in
                Text(verseNumber)
                    .fontWeight(.bold)
                    .padding(.bottom, 2)
                    .foregroundColor(.gray)
                    .relativeFont(CGFloat(viewModel.fontSize) * 0.80)
            }
            if transliterate {
                viewModel.transliteration.map { transliteration in
                    Text(transliteration).relativeFont(CGFloat(viewModel.fontSize))
                }
            }
            Text(viewModel.verseText)
                .italic(viewModel.isItalicized)
                .relativeFont(CGFloat(viewModel.fontSize))
        }.fixedSize(horizontal: false, vertical: true).padding(.bottom, 5).lineSpacing(5)
    }
}

#if DEBUG
struct VerseLineView_Previews: PreviewProvider, PrefireProvider {
    static var previews: some View {

        var doNotTransliterate = false
        let doNotTransliterateBinding = Binding<Bool>(
            get: {doNotTransliterate}, set: {doNotTransliterate = $0}
        )
        let regularVerseViewModels = [VerseLineViewModel(verseType: .verse, verseNumber: "1", verseText: "Drink! A river pure and clear that's flowing from the throne"),
                                      VerseLineViewModel(verseType: .chorus, verseText: "Eat! The tree of life with fruits abundant, richly grown"),
                                      VerseLineViewModel(verseType: .note, verseText: "This is a note")]
        let regularVerse = VStack(alignment: .leading) {
            VerseLineView(viewModel: regularVerseViewModels[0], transliterate: doNotTransliterateBinding)
            VerseLineView(viewModel: regularVerseViewModels[1], transliterate: doNotTransliterateBinding)
        }

        let largeTextVerseViewModels = [VerseLineViewModel(verseType: .verse, verseNumber: "1", verseText: "Drink! A river pure and clear that's flowing from the throne"),
                                        VerseLineViewModel(verseType: .chorus, verseText: "Eat! The tree of life with fruits abundant, richly grown"),
                                        VerseLineViewModel(verseType: .note, verseText: "This is a note")]
        largeTextVerseViewModels[0].fontSize = 18.0
        largeTextVerseViewModels[1].fontSize = 18.0
        let largeText = VStack(alignment: .leading) {
            VerseLineView(viewModel: largeTextVerseViewModels[0], transliterate: doNotTransliterateBinding)
            VerseLineView(viewModel: largeTextVerseViewModels[1], transliterate: doNotTransliterateBinding)
        }

        let extraLargeTextVerseViewModels = [VerseLineViewModel(verseType: .verse, verseNumber: "1", verseText: "Drink! A river pure and clear that's flowing from the throne"),
                                             VerseLineViewModel(verseType: .chorus, verseText: "Eat! The tree of life with fruits abundant, richly grown"),
                                             VerseLineViewModel(verseType: .note, verseText: "This is a note")]
        extraLargeTextVerseViewModels[0].fontSize = 24.0
        extraLargeTextVerseViewModels[1].fontSize = 24.0
        let extraLargeText = VStack(alignment: .leading) {
            VerseLineView(viewModel: extraLargeTextVerseViewModels[0], transliterate: doNotTransliterateBinding)
            VerseLineView(viewModel: extraLargeTextVerseViewModels[1], transliterate: doNotTransliterateBinding)
        }

        var transliterate = true
        let transliterateBinding = Binding<Bool>(
            get: {transliterate}, set: {transliterate = $0}
        )
        let transliterationViewModels = [VerseLineViewModel(verseType: .verse, verseNumber: "1", lineEntity: LineEntity(lineContent: "喝！从宝座流出", transliteration: "Hē! Cóng bǎozuò liúchū")),
                                         VerseLineViewModel(verseType: .chorus, lineEntity: LineEntity(lineContent: "纯净生命河的水", transliteration: "Chúnjìng shēngmìng hé de shuǐ"))]
        let transliteration = VStack(alignment: .leading) {
            VerseLineView(viewModel: transliterationViewModels[0], transliterate: transliterateBinding)
            VerseLineView(viewModel: transliterationViewModels[1], transliterate: transliterateBinding)
        }

        return Group {
            regularVerse.previewDisplayName("regular verse")
            largeText.previewDisplayName("large text")
            extraLargeText.previewDisplayName("extra large text")
            transliteration.previewDisplayName("verse with transliteration")
        }.padding().previewLayout(.sizeThatFits)
    }
}
#endif

struct VerseView: View {

    let viewModel: VerseViewModel
    @Binding var transliterate: Bool

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(viewModel.verseLines, id: \.self) { verseLine in
                VerseLineView(viewModel: verseLine, transliterate: self.$transliterate)
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack(alignment: .leading) {
        VerseView(viewModel: VerseViewModel(verseType: .verse,
                                            verseNumber: "1",
                                            verseLines: ["Drink! A river pure and clear that's flowing from the throne", "Eat! The tree of life with fruits abundant, richly grown",
                                                         "Look! No need of lamp nor sun nor moon to keep it bright, for", "  Here this is no night!"]),
                  transliterate: .constant(false))
        VerseView(viewModel: VerseViewModel(verseType: .verse,
                                            verseNumber: "Chorus",
                                            verseLines: ["Do come, oh, do come,", "Says Spirit and the Bride:", "Do come, oh, do come,", "Let him that heareth, cry.",
                                                         "Do come, oh, do come,", "Let him who thirsts and will", "  Take freely the water of life!"]),
                  transliterate: .constant(false))
    }.padding()
}
