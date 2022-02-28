#if DEBUG
import Combine
import Foundation

class SongbaseStoreTestImpl: SongbaseStore {

    var databaseInitializedProperly: Bool = true

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
