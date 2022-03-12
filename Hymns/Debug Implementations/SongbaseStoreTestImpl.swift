#if DEBUG
import Combine
import Foundation

class SongbaseStoreTestImpl: SongbaseStore {

    private let songbaseStore = ["2|1151": SongbaseSong(bookId: 2, bookIndex: 1151,
                                                        title: "Songbase version of Hymn 1151 title",
                                                        language: "english",
                                                        lyrics: "Songbase version of Hymn 1151 lyrics",
                                                        chords: "[G]Songbase version of Hymn 1151 chords")]

    var databaseInitializedProperly: Bool = true

    func getHymn(bookId: Int, bookIndex: Int) -> AnyPublisher<SongbaseSong?, ErrorType> {
        let key = "\(bookId)|\(bookIndex)"
        return Just(songbaseStore[key]).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }

    func searchHymn(_ searchParameter: String) -> AnyPublisher<[SongbaseSearchResultEntity], ErrorType> {
        Just([SongbaseSearchResultEntity]()).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }

    func getAllSongs() -> AnyPublisher<[SongbaseResultEntity], ErrorType> {
        Just([SongbaseResultEntity]()).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }
}
#endif
