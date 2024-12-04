import Foundation
import Resolver

class AllSongsViewModel: ObservableObject {

    @Published var hymnTypes: [HymnType]

    init() {
        hymnTypes = [.classic, .newSong, .children, .howardHigashi, .blueSongbook, .beFilled, .dutch, .liederbuch, .german,
                     .chinese, .chineseSupplement, .cebuano, .tagalog, .french, .spanish, .korean, .japanese, .indonesian, .farsi,
                     .russian]
    }
}

extension Resolver {
    public static func registerAllSongsViewModel() {
        register {AllSongsViewModel()}.scope(.graph)
    }
}
