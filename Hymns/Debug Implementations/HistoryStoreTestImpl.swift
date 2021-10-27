#if DEBUG
import Combine
import Foundation

class HistoryStoreTestImpl: HistoryStore {

    var results = [RecentSong(hymnIdentifier: classic1151, songTitle: "classic1151"),
                   RecentSong(hymnIdentifier: classic40, songTitle: "classic40"),
                   RecentSong(hymnIdentifier: classic2, songTitle: "classic2"),
                   RecentSong(hymnIdentifier: classic3, songTitle: "classic3")]

    func clearHistory() throws {
        results = [RecentSong]()
    }

    func recentSongs() -> AnyPublisher<[RecentSong], ErrorType> {
        Just(results).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }

    func storeRecentSong(hymnToStore hymnIdentifier: HymnIdentifier, songTitle: String) {
        results.append(RecentSong(hymnIdentifier: hymnIdentifier, songTitle: songTitle))
    }
}
#endif
