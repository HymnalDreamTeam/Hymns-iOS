import SwiftUI

public struct ChordWordView: View {

    @ObservedObject var viewModel: ChordWordViewModel

    init(_ viewModel: ChordWordViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            viewModel.chords.map { chords in
                Text(chords.isEmpty ? " " : chords)
                    .foregroundColor(.accentColor)
                    .frame(alignment: .topLeading)
                    .padding(.bottom, 8)
                    .relativeFont(CGFloat(viewModel.fontSize))
            }
            Text(viewModel.word).frame(alignment: .bottomLeading).relativeFont(CGFloat(viewModel.fontSize))
        }
    }
}

 #if DEBUG
 struct ChordWordView_Previews: PreviewProvider {
    static var previews: some View {
        let multipleChordsViewModel = ChordWordViewModel(ChordWordEntity("Drink", chords: "Am G"))
        let multipleChords = ChordWordView(multipleChordsViewModel)

        let singleChordViewModel = ChordWordViewModel(ChordWordEntity("Drink", chords: "Am"))
        let singleChord = ChordWordView(singleChordViewModel)

        let emptyChordsViewModel = ChordWordViewModel(ChordWordEntity("Drink", chords: ""))
        let emptyChords = ChordWordView(emptyChordsViewModel)

        let noChordsViewModel = ChordWordViewModel(ChordWordEntity("Drink"))
        let noChords = ChordWordView(noChordsViewModel)

        Group {
            multipleChords.previewLayout(.sizeThatFits).previewDisplayName("Multiple chords")
            singleChord.previewLayout(.sizeThatFits).previewDisplayName("Single chord")
            emptyChords.previewLayout(.sizeThatFits).previewDisplayName("Empty chords")
            noChords.previewLayout(.sizeThatFits).previewDisplayName("Nil chord")
        }
    }
 }
 #endif
