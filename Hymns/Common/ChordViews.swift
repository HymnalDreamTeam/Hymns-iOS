import SwiftUI

public struct ChordWordView: View {

    @ObservedObject var chordWord: ChordWord

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
                    .font(.system(size: CGFloat(chordWord.fontSize)))
            }
            Text(chordWord.word).frame(alignment: .bottomLeading).font(.system(size: CGFloat(chordWord.fontSize)))
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
