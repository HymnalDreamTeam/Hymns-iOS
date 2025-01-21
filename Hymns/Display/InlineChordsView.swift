import Foundation
import MobileCoreServices
import Prefire
import SwiftUI

public struct InlineChordsView: View {

    @ObservedObject private var viewModel: InlineChordsViewModel

    init(viewModel: InlineChordsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            viewModel.transpositionLabelText.map { transpositionLabel in
                HStack {
                    Spacer()
                    Button {
                        self.viewModel.transpose(-1)
                    } label: {
                        Image(systemName: "minus")
                            .accessibilityLabel(Text("Transpose down a half step",
                                                     comment: "A11y label for button transposing down."))
                            .font(.system(size: smallButtonSize))
                            .foregroundColor(.primary)
                            .padding(.leading)
                    }
                    Button {
                        self.viewModel.resetTransposition()
                    } label: {
                        Text(transpositionLabel)
                            .font(.subheadline)
                            .foregroundColor(self.viewModel.transpositionLabelColor)
                    }
                    Button {
                        self.viewModel.transpose(1)
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityLabel(Text("Transpose up a half step",
                                                     comment: "A11y label for button transposing up."))
                            .font(.system(size: smallButtonSize))
                            .foregroundColor(.primary)
                    }
                }
            }
            ForEach(self.viewModel.chordLines) { chordLine in
                WrappedHStack(items: .constant(chordLine.chordWords),
                              horizontalSpacing: 2, verticalSpacing: 0) { chordWord in
                    ChordWordView(chordWord)
                }
            }
        }.preference(key: DisplayHymnView.DisplayTypeKey.self, value: .inlineChords).padding(.horizontal)
    }
}

 #if DEBUG
struct InlineChordsView_Previews: PreviewProvider, PrefireProvider {

    static var previews: some View {
        let hymnsViewModel = InlineChordsViewModel(chordLines: [
            // Verse 1
            ChordLineEntity(createChordLine("1")),
            ChordLineEntity(createChordLine("[G]Drink! A river pure and clear")),
            ChordLineEntity(createChordLine("That’s [G7]flowing from the throne;")),
            ChordLineEntity(createChordLine("[C]Eat! The tree of life with fruits")),
            ChordLineEntity(createChordLine("[G]Here there [D7]is no [G-C-G]night!")),
            ChordLineEntity(createChordLine("")),
            // Chorus
            ChordLineEntity(createChordLine("")),
            ChordLineEntity(createChordLine("  Do come, oh, do come,")),
            ChordLineEntity(createChordLine("  Says [G7]Spirit and the Bride:")),
            ChordLineEntity(createChordLine("  []Do come, oh, do come,")),
            ChordLineEntity(createChordLine("  Let [B7]him who thirsts and [Em]will")),
            ChordLineEntity(createChordLine("  Take [G]freely the [D]water of [G]l[C]i[G]fe!")),
            ChordLineEntity(createChordLine("")),
            // Verse 3
            ChordLineEntity(createChordLine("2")),
            ChordLineEntity(createChordLine("Christ, our river, Christ, our water,")),
            ChordLineEntity(createChordLine("Springing from within;")),
            ChordLineEntity(createChordLine("Christ, our tree, and Christ, the fruits,")),
            ChordLineEntity(createChordLine("To be enjoyed therein,")),
            ChordLineEntity(createChordLine("Christ, our day, and Christ, our light,")),
            ChordLineEntity(createChordLine("and Christ, our morningstar:")),
            ChordLineEntity(createChordLine("Christ, our everything!"))
         ])
        let hymns = InlineChordsView(viewModel: hymnsViewModel)

        let transposedViewModel = InlineChordsViewModel(chordLines: [
            // Verse 1
            ChordLineEntity(createChordLine("1")),
            ChordLineEntity(createChordLine("[G]Drink! A river pure and clear")),
            ChordLineEntity(createChordLine("That’s [G7]flowing from the throne;")),
            ChordLineEntity(createChordLine("[C]Eat! The tree of life with fruits")),
            // Make sure long line wraps correctly
            ChordLineEntity(createChordLine("[G]Here there [D7]is no [G-C-G]night! [G]Here there [D7]is no [G-C-G]night! [G]Here there [D7]is no [G-C-G]night!")),
            ChordLineEntity(createChordLine("")),
            // Chorus
            ChordLineEntity(createChordLine("")),
            ChordLineEntity(createChordLine("  Do come, oh, do come,")),
            ChordLineEntity(createChordLine("  Says [G7]Spirit and the Bride:")),
            ChordLineEntity(createChordLine("  []Do come, oh, do come,")),
            ChordLineEntity(createChordLine("  Let [B7]him who thirsts and [Em]will")),
            ChordLineEntity(createChordLine("  Take [G]freely the [D]water of [G]l[C]i[G]fe!")),
            ChordLineEntity(createChordLine(""))
         ])
        transposedViewModel.transpose(10)
        let transposed = InlineChordsView(viewModel: transposedViewModel)

        let noChordsViewModel = InlineChordsViewModel(chordLines: [
            // Verse 1
            ChordLineEntity(createChordLine("1")),
            ChordLineEntity(createChordLine("Drink! A river pure and clear")),
            ChordLineEntity(createChordLine("That’s flowing from the throne;")),
            ChordLineEntity(createChordLine("Eat! The tree of life with fruits")),
            ChordLineEntity(createChordLine("Here there is no night!")),
            ChordLineEntity(createChordLine("")),
            // Chorus
            ChordLineEntity(createChordLine("")),
            ChordLineEntity(createChordLine("  Do come, oh, do come,")),
            ChordLineEntity(createChordLine("  Says Spirit and the Bride:")),
            ChordLineEntity(createChordLine("  []Do come, oh, do come,")),
            ChordLineEntity(createChordLine("  Let him who thirsts and will")),
            ChordLineEntity(createChordLine("  Take []freely the []water of []l[]i[]fe!")),
            ChordLineEntity(createChordLine(""))
        ])
        let noChords = InlineChordsView(viewModel: noChordsViewModel)

        return Group {
            hymns.previewDisplayName("Hymn 1151")
            transposed.previewDisplayName("Transposed chords")
            noChords.previewDisplayName("No chords")
        }.snapshot(delay: 0.2)
    }
 }
 #endif
