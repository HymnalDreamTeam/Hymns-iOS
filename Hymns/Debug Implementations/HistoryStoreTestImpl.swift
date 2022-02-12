#if DEBUG
import Combine
import Foundation

class HistoryStoreTestImpl: HistoryStore {

    var results = [RecentSong(hymnIdentifier: classic1151, songTitle: "classic1151"),
                   RecentSong(hymnIdentifier: classic40, songTitle: "classic40"),
                   RecentSong(hymnIdentifier: classic2, songTitle: "Hymn 2: Classic 2"),
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
