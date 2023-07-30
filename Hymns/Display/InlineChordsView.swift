import Foundation
import MobileCoreServices
import SwiftUI

public struct InlineChordsView: View {

    @ObservedObject private var viewModel: InlineChordsViewModel

    init(viewModel: InlineChordsViewModel) {
        self.viewModel = viewModel
    }
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                viewModel.transpositionLabelText.map { transpositionLabel in
                    HStack {
                        Spacer()
                        Button {
                            self.viewModel.transpose(-1)
                        } label: {
                            Image(systemName: "minus").accessibilityLabel(Text("Transpose down a half step", comment: "A11y label for button transposing down."))
                                .font(.system(size: smallButtonSize)).foregroundColor(.primary).padding(.leading)
                        }
                        Button {
                            self.viewModel.resetTransposition()
                        } label: {
                            Text(transpositionLabel).font(.subheadline).foregroundColor(self.viewModel.transpositionLabelColor)
                        }
                        Button {
                            self.viewModel.transpose(1)
                        } label: {
                            Image(systemName: "plus").accessibilityLabel(Text("Transpose up a half step", comment: "A11y label for button transposing up."))
                                .font(.system(size: smallButtonSize)).foregroundColor(.primary)
                        }
                    }
                }
                ForEach(self.viewModel.chords) { chordLine in
                    WrappedHStack(items: .constant(chordLine.words), horizontalSpacing: 2, verticalSpacing: 0) { chordWord in
                        ChordWordView(chordWord)
                    }
                }
            }
        }.padding(.horizontal)
    }
}

 #if DEBUG
 struct InlineChordsView_Previews: PreviewProvider {

    static var previews: some View {
        let hymnsViewModel = InlineChordsViewModel(chords: [
            // Verse 1
            ChordLine("1"),
            ChordLine("[G]Drink! A river pure and clear"),
            ChordLine("That’s [G7]flowing from the throne;"),
            ChordLine("[C]Eat! The tree of life with fruits"),
            ChordLine("[G]Here there [D7]is no [G-C-G]night!"),
            ChordLine(""),
            // Chorus
            ChordLine(""),
            ChordLine("  Do come, oh, do come,"),
            ChordLine("  Says [G7]Spirit and the Bride:"),
            ChordLine("  []Do come, oh, do come,"),
            ChordLine("  Let [B7]him who thirsts and [Em]will"),
            ChordLine("  Take [G]freely the [D]water of [G]l[C]i[G]fe!"),
            ChordLine(""),
            // Verse 3
            ChordLine("2"),
            ChordLine("Christ, our river, Christ, our water,"),
            ChordLine("Springing from within;"),
            ChordLine("Christ, our tree, and Christ, the fruits,"),
            ChordLine("To be enjoyed therein,"),
            ChordLine("Christ, our day, and Christ, our light,"),
            ChordLine("and Christ, our morningstar:"),
            ChordLine("Christ, our everything!")
         ])
        let hymns = InlineChordsView(viewModel: hymnsViewModel)

        let transposedViewModel = InlineChordsViewModel(chords: [
            // Verse 1
            ChordLine("1"),
            ChordLine("[G]Drink! A river pure and clear"),
            ChordLine("That’s [G7]flowing from the throne;"),
            ChordLine("[C]Eat! The tree of life with fruits"),
            ChordLine("[G]Here there [D7]is no [G-C-G]night!"),
            ChordLine(""),
            // Chorus
            ChordLine(""),
            ChordLine("  Do come, oh, do come,"),
            ChordLine("  Says [G7]Spirit and the Bride:"),
            ChordLine("  []Do come, oh, do come,"),
            ChordLine("  Let [B7]him who thirsts and [Em]will"),
            ChordLine("  Take [G]freely the [D]water of [G]l[C]i[G]fe!"),
            ChordLine("")
         ])
        transposedViewModel.transpose(10)
        let transposed = InlineChordsView(viewModel: transposedViewModel)

        let noChordsViewModel = InlineChordsViewModel(chords: [
            // Verse 1
            ChordLine("1"),
            ChordLine("Drink! A river pure and clear"),
            ChordLine("That’s flowing from the throne;"),
            ChordLine("Eat! The tree of life with fruits"),
            ChordLine("Here there is no night!"),
            ChordLine(""),
            // Chorus
            ChordLine(""),
            ChordLine("  Do come, oh, do come,"),
            ChordLine("  Says Spirit and the Bride:"),
            ChordLine("  []Do come, oh, do come,"),
            ChordLine("  Let him who thirsts and will"),
            ChordLine("  Take []freely the []water of []l[]i[]fe!"),
            ChordLine("")
        ])
        let noChords = InlineChordsView(viewModel: noChordsViewModel)

        return Group {
            hymns.previewDisplayName("Hymn 1151")
            transposed.previewDisplayName("Transposed chords")
            noChords.previewDisplayName("no chords")
        }
    }
 }
 #endif
