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

     private static let hymn1151Chords = [
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
     ]

    static var previews: some View {
        let viewModel = InlineChordsViewModel(chords: hymn1151Chords)
        return InlineChordsView(viewModel: viewModel)
    }
 }
 #endif
