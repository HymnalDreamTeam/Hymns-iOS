import SwiftUI

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
