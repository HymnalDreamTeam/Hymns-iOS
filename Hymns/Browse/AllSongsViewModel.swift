import Resolver

class AllSongsViewModel: ObservableObject {

    @Published var hymnTypes: [HymnType]

    init() {
        hymnTypes = [.classic, .newSong, .children, .howardHigashi, .songbase, .dutch, .german, .chinese, .chineseSupplement,
                     .cebuano, .tagalog, .french, .spanish, .korean, .japanese, .farsi]
    }
}

extension Resolver {
    public static func registerAllSongsViewModel() {
        register {AllSongsViewModel()}.scope(.graph)
    }
}
