import Foundation

class InlineChordsViewModel: ObservableObject {

    @Published var chords: [ChordLine] = [ChordLine]()

    init(chords: [ChordLine]) {
        self.chords = chords
    }
}
