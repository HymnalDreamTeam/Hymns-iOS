#if DEBUG
import Combine
import Foundation

class HistoryStoreTestImpl: HistoryStore {

    var results = [RecentSong(hymnIdentifier: classic1151.hymnIdentifier!, songTitle: "classic1151"),
                   RecentSong(hymnIdentifier: classic40.hymnIdentifier!, songTitle: "classic40"),
                   RecentSong(hymnIdentifier: classic2.hymnIdentifier!, songTitle: "Classic 2"),
                   RecentSong(hymnIdentifier: classic3.hymnIdentifier!, songTitle: "classic3")]

    func clearHistory() throws {
        results = [RecentSong]()
    }

    func recentSongs() -> AnyPublisher<[RecentSong], ErrorType> {
        Just(results).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }

    func storeRecentSong(hymnToStore hymnIdentifier: HymnIdentifier, songTitle: String) {
        let songToStore = RecentSong(hymnIdentifier: hymnIdentifier, songTitle: songTitle)
        if let index = results.firstIndex(of: songToStore) {
            results.remove(at: index)
            results.insert(songToStore, at: 0)
        } else {
            results.append(songToStore)
        }
    }
}
#endif
