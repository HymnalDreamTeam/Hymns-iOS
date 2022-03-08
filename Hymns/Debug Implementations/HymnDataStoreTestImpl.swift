#if DEBUG
import Combine
import Foundation

class HymnDataStoreTestImpl: HymnDataStore {

    private var hymnStore = [
        classic1151: classic1151Entity,
        chinese216: chinese216Entity,
        classic2: classic2Entity,
        classic3: classic3Entity,
        classic40: classic40Entity,
        howardiHigsashi2: howardHigashi2Entity]
    private let searchStore =
        ["search param":
            [SearchResultEntity(hymnType: .classic, hymnNumber: "1151", queryParams: nil, title: "Click me!", matchInfo: Data(repeating: 0, count: 8)),
             SearchResultEntity(hymnType: .chinese, hymnNumber: "4", queryParams: nil, title: "Don't click!", matchInfo: Data(repeating: 1, count: 8))]]
    private let categories =
        [CategoryEntity(category: "category 1", subcategory: "subcategory 1", count: 5),
         CategoryEntity(category: "category 1", subcategory: "subcategory 2", count: 1),
         CategoryEntity(category: "category 2", subcategory: "subcategory 1", count: 9)]
    private let songResultsByCategory =
        [("category 1 h subcategory 2"):
            [SongResultEntity(hymnType: .classic, hymnNumber: "1151", queryParams: nil, title: "Click me!"),
             SongResultEntity(hymnType: .newTune, hymnNumber: "37", queryParams: nil, title: "Don't click!"),
             SongResultEntity(hymnType: .classic, hymnNumber: "883", queryParams: nil, title: "Don't click either!")]]
    private let songResultsByHymnCode =
        [("171214436716555"):
            [SongResultEntity(hymnType: .classic, hymnNumber: "1151", queryParams: nil, title: "Click me!"),
             SongResultEntity(hymnType: .classic, hymnNumber: "883", queryParams: nil, title: "Don't click either!")]]
    private let scriptureSongs =
        [ScriptureEntity(title: "chinese1151", hymnType: .chinese, hymnNumber: "155", queryParams: nil, scriptures: "Hosea 14:8"),
         ScriptureEntity(title: "Click me!", hymnType: .classic, hymnNumber: "1151", queryParams: nil, scriptures: "Revelation 22"),
         ScriptureEntity(title: "Don't click me!", hymnType: .spanish, hymnNumber: "1151", queryParams: nil, scriptures: "Revelation"),
         ScriptureEntity(title: "chinese24", hymnType: .chinese, hymnNumber: "24", queryParams: nil, scriptures: "Genesis 1:26"),
         ScriptureEntity(title: "chinese33", hymnType: .chinese, hymnNumber: "33", queryParams: nil, scriptures: "Genesis 1:1")]
    private let howardHigashiSongs = Array(1...50).map { num -> SongResultEntity in
        SongResultEntity(hymnType: .howardHigashi, hymnNumber: "\(num)", queryParams: nil, title: "Higashi title \(num)")
    }

    var databaseInitializedProperly: Bool = true

    func saveHymn(_ entity: HymnEntity) {
        guard let hymnType = HymnType.fromAbbreviatedValue(entity.hymnType) else {
            fatalError()
        }
        let hymnIdentifier = HymnIdentifier(hymnType: hymnType, hymnNumber: entity.hymnNumber, queryParams: entity.queryParams.deserializeFromQueryParamString)
        hymnStore[hymnIdentifier] = entity
    }

    func getHymn(_ hymnIdentifier: HymnIdentifier) -> AnyPublisher<HymnEntity?, ErrorType> {
        Just(hymnStore[hymnIdentifier]).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }

    func searchHymn(_ searchParamter: String) -> AnyPublisher<[SearchResultEntity], ErrorType> {
        Just(searchStore[searchParamter] ?? [SearchResultEntity]()).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }

    func getAllCategories() -> AnyPublisher<[CategoryEntity], ErrorType> {
        Just([CategoryEntity]()).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }

    func getCategories(by hymnType: HymnType) -> AnyPublisher<[CategoryEntity], ErrorType> {
        Just(categories).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }

    func getResultsBy(category: String, hymnType: HymnType?, subcategory: String?) -> AnyPublisher<[SongResultEntity], ErrorType> {
        Just(songResultsByCategory["\(category) \(hymnType?.abbreviatedValue ?? "") \(subcategory ?? "")"] ?? [SongResultEntity]())
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
