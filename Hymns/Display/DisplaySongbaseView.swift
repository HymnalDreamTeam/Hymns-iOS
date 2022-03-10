import Foundation
import MobileCoreServices
import SwiftUI

public struct DisplaySongbaseView: View {

    @ObservedObject private var viewModel: DisplaySongbaseViewModel

    init(viewModel: DisplaySongbaseViewModel) {
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
        }.padding().onAppear {
            viewModel.fetchHymn()
        }
    }
}

 #if DEBUG
 struct DisplaySongbaseView_Previews: PreviewProvider {

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
        let viewModel = DisplaySongbaseViewModel(bookId: 99, bookIndex: 1151)
        viewModel.chords = hymn1151Chords
        return DisplaySongbaseView(viewModel: viewModel)
    }
 }
 #endif

public struct ChordWordView: View {

    let chordWord: ChordWord

    init(_ chordWord: ChordWord) {
        self.chordWord = chordWord
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            chordWord.chordString.map { chordString in
                Text(chordString)
                    .foregroundColor(.accentColor)
                    .frame(alignment: .topLeading)
                    .padding(.bottom, 8)
            }
            Text(chordWord.word).frame(alignment: .bottomLeading)
        }
    }
}

 #if DEBUG
 struct ChordWordView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChordWordView(ChordWord("Drink", chords: ["Am", "G"])).previewLayout(.sizeThatFits).previewDisplayName("Multiple chords")
            ChordWordView(ChordWord("Drink", chords: ["Am"])).previewLayout(.sizeThatFits).previewDisplayName("Single chord")
            ChordWordView(ChordWord("Drink")).previewLayout(.sizeThatFits).previewDisplayName("Empty chords")
            ChordWordView(ChordWord("Drink", chords: nil)).previewLayout(.sizeThatFits).previewDisplayName("Nil chord")
        }
    }
 }
 #endif
