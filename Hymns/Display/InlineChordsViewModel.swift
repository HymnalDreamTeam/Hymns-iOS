import Foundation
import SwiftUI

class InlineChordsViewModel: ObservableObject {

    @Published var chordLines: [ChordLineViewModel] = [ChordLineViewModel]()
    @Published var transpositionLabelText: String?
    @Published var transpositionLabelColor: Color = .primary

    var transposition = 0

    init(chordLines: [ChordLineEntity]) {
        self.chordLines = chordLines.map({ chordLine in
            ChordLineViewModel(chordLine: chordLine)
        })
        self.syncTranspositionLabel()
    }

    func transpose(_ steps: Int) {
        transposition += steps
        chordLines.forEach { chordLine in
            chordLine.transpose(steps)
        }
        syncTranspositionLabel()
    }

    func resetTransposition() {
        let stepsToTranspose = transposition
        for _ in 0..<abs(transposition) {
            transpose(stepsToTranspose > 0 ? -1 : 1)
        }
        syncTranspositionLabel()
    }

    private func syncTranspositionLabel() {
        if !chordLines.contains(where: { $0.hasChords }) {
            transpositionLabelText = nil
            return
        }

        if transposition == 0 {
            transpositionLabelText = NSLocalizedString("Transpose", comment: "Label for transpose indicator, with 0 transposition.")
            transpositionLabelColor = .primary
        } else {
            transpositionLabelText = String(format: NSLocalizedString("Capo %@", comment: "Label for transpose indicator, with nonzero transposition."),
                                            String(format: "%+d", transposition))
            transpositionLabelColor = .accentColor
        }
    }
}
