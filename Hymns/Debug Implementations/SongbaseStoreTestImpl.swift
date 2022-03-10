#if DEBUG
import Combine
import Foundation

class SongbaseStoreTestImpl: SongbaseStore {

    var databaseInitializedProperly: Bool = true

    func getHymn(bookId: Int, bookIndex: Int) -> AnyPublisher<SongbaseSong?, ErrorType> {
        Just(nil).mapError({ _ -> ErrorType in
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
