#if DEBUG
import Combine
import Foundation

class HymnDataStoreTestImpl: HymnDataStore {
    static var songId: Int64 = 0

    /// Fake storage unit that will pretend to store hymns on the disk, but really just keep it in memory.
    private var fakeDatabase = [
        classic1151.songId: classic1151Entity,
        classic1152.songId: classic1152Entity,
        chineseSupplement216.songId: chineseSupplement216Entity,
        classic2.songId: classic2Entity,
        classic3.songId: classic3Entity,
        classic40.songId: classic40Entity,
        howardiHigsashi2.songId: howardHigashi2Entity]

    /// Fake storage unit that will pretend to store hymn ids on the disk, but really just keep it in memory.
    private var fakeHymnIds = [
        classic1151,
        classic1152,
        chineseSupplement216,
        classic2,
        classic3,
        classic40,
        howardiHigsashi2]

    private let searchStore =
        ["search param":
            [SearchResultEntity(hymnType: .classic, hymnNumber: "1151", title: "Click me!", matchInfo: Data(repeating: 0, count: 8), songId: 1),
             SearchResultEntity(hymnType: .chinese, hymnNumber: "4", title: "Don't click!", matchInfo: Data(repeating: 1, count: 8), songId: 1)]]
    private let categories =
        [CategoryEntity(category: "category 1", subcategory: "subcategory 1", count: 5),
         CategoryEntity(category: "category 1", subcategory: "subcategory 2", count: 1),
         CategoryEntity(category: "category 2", subcategory: "subcategory 1", count: 9)]
    private let songResultsByCategory =
        [("category 1 h subcategory 2"):
            [SongResultEntity(hymnType: .classic, hymnNumber: "1151", title: "Click me!"),
             SongResultEntity(hymnType: .newTune, hymnNumber: "37", title: "Don't click!"),
             SongResultEntity(hymnType: .classic, hymnNumber: "883", title: "Don't click either!")],
         ("song's category"):
             [SongResultEntity(hymnType: .classic, hymnNumber: "1151", title: "Click me!"),
              SongResultEntity(hymnType: .newTune, hymnNumber: "37", title: "Don't click!"),
              SongResultEntity(hymnType: .classic, hymnNumber: "883", title: "Don't click either!")]]
    private let songResultsByAuthor =
        [("Barack Obama"):
            [SongResultEntity(hymnType: .classic, hymnNumber: "113", title: "Hymn 113"),
             SongResultEntity(hymnType: .classic, hymnNumber: "990", title: "Hymn 990")]]
    private let songResultsByHymnCode =
        [("171214436716555"):
            [SongResultEntity(hymnType: .classic, hymnNumber: "1151", title: "Click me!"),
             SongResultEntity(hymnType: .classic, hymnNumber: "883", title: "Don't click either!")]]
    private let scriptureSongs =
        [ScriptureEntity(title: "chinese1151", hymnType: .chinese, hymnNumber: "155", scriptures: "Hosea 14:8"),
         ScriptureEntity(title: "Click me!", hymnType: .classic, hymnNumber: "1151", scriptures: "Revelation 22"),
         ScriptureEntity(title: "Don't click me!", hymnType: .spanish, hymnNumber: "1151", scriptures: "Revelation"),
         ScriptureEntity(title: "chinese24", hymnType: .chinese, hymnNumber: "24", scriptures: "Genesis 1:26"),
         ScriptureEntity(title: "chinese33", hymnType: .chinese, hymnNumber: "33", scriptures: "Genesis 1:1")]
    private let howardHigashiSongs = Array(1...50).map { num -> SongResultEntity in
        SongResultEntity(hymnType: .howardHigashi, hymnNumber: "\(num)", title: "Higashi title \(num)")
    }

    var databaseInitializedProperly: Bool = true

    func saveHymn(_ entity: HymnEntity) -> Int64? {
        HymnDataStoreTestImpl.songId += 1
        fakeDatabase[entity.id!] = entity
        return HymnDataStoreTestImpl.songId
    }

    func saveHymn(_ entity: HymnIdEntity) {
        fakeHymnIds.append(entity)
    }

    func getHymn(_ hymnIdentifier: HymnIdentifier) -> AnyPublisher<HymnReference?, ErrorType> {
        let hymnIdEntity = fakeHymnIds.first(where: { hymnIdEntity in
            guard let identifier = hymnIdEntity.hymnIdentifier else {
                return false
            }
            return hymnIdentifier == identifier
        })
        guard let hymnIdEntity = hymnIdEntity, let hymnEntity = fakeDatabase[hymnIdEntity.songId] else {
            return Just(nil).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }
        return Just(HymnReference(hymnIdEntity: hymnIdEntity, hymnEntity: hymnEntity)).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }

    func searchHymn(_ searchParamter: String) -> AnyPublisher<[SearchResultEntity], ErrorType> {
        Just(searchStore[searchParamter] ?? [SearchResultEntity]()).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }

    func getCategories(by hymnType: HymnType) -> AnyPublisher<[CategoryEntity], ErrorType> {
        Just(categories).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }

    func getResultsBy(category: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        Just(songResultsByCategory[category] ?? [SongResultEntity]())
            .mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
    }

    func getResultsBy(category: String, hymnType: HymnType) -> AnyPublisher<[SongResultEntity], ErrorType> {
        Just(songResultsByCategory["\(category) \(hymnType.abbreviatedValue)"] ?? [SongResultEntity]())
            .mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
    }

    func getResultsBy(category: String, subcategory: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        Just(songResultsByCategory["\(category) \(subcategory)"] ?? [SongResultEntity]())
            .mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
    }

    func getResultsBy(category: String, subcategory: String, hymnType: HymnType) -> AnyPublisher<[SongResultEntity], ErrorType> {
        Just(songResultsByCategory["\(category) \(hymnType.abbreviatedValue) \(subcategory)"] ?? [SongResultEntity]())
            .mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
    }

    func getResultsBy(subcategory: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        Just(songResultsByCategory["\(subcategory)"] ?? [SongResultEntity]())
            .mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
    }

    func getResultsBy(subcategory: String, hymnType: HymnType) -> AnyPublisher<[SongResultEntity], ErrorType> {
        Just(songResultsByCategory["\(hymnType.abbreviatedValue) \(subcategory)"] ?? [SongResultEntity]())
            .mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
    }

    func getResultsBy(author: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        Just(songResultsByAuthor[author] ?? [SongResultEntity]())
            .mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
    }

    func getResultsBy(composer: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        Just([SongResultEntity]()) // Populate list in when we have tests that use it
            .mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
    }

    func getResultsBy(key: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        Just([SongResultEntity]()) // Populate list in when we have tests that use it
            .mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
    }

    func getResultsBy(time: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        Just([SongResultEntity]()) // Populate list in when we have tests that use it
            .mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
    }

    func getResultsBy(meter: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        Just([SongResultEntity]()) // Populate list in when we have tests that use it
            .mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
    }

    func getResultsBy(scriptures: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        Just([SongResultEntity]()) // Populate list in when we have tests that use it
            .mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
    }

    func getResultsBy(hymnCode: String) -> AnyPublisher<[SongResultEntity], ErrorType> {
        Just(songResultsByHymnCode[hymnCode] ?? [SongResultEntity]())
            .mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
    }

    func getScriptureSongs() -> AnyPublisher<[ScriptureEntity], ErrorType> {
        Just(scriptureSongs).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }

    func getAllSongs(hymnType: HymnType) -> AnyPublisher<[SongResultEntity], ErrorType> {
        if hymnType == .howardHigashi {
            return Just(howardHigashiSongs).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }

        return Just([SongResultEntity]()).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }
}
#endif
