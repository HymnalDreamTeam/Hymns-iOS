import Combine
import Foundation
import Resolver

class DisplaySongbaseViewModel: ObservableObject {

    @Published var chords: [ChordLine] = [ChordLine]()

    init(chords: [ChordLine]) {
        self.chords = chords
    }
}
