#if DEBUG
import Combine
import Foundation

class FavoriteStoreTestImpl: FavoriteStore {

    var entities = [FavoriteEntity(hymnIdentifier: classic40.hymnIdentifier!, songTitle: "classic40"),
                    FavoriteEntity(hymnIdentifier: classic2.hymnIdentifier!, songTitle: "classic2"),
                    FavoriteEntity(hymnIdentifier: classic1151.hymnIdentifier!, songTitle: "classic1151")]

    func storeFavorite(_ entity: FavoriteEntity) {
        entities.append(entity)
    }

    func deleteFavorite(primaryKey: String) {
        entities.removeAll { entity -> Bool in
            entity.primaryKey == primaryKey
        }
    }

    func favorites() -> AnyPublisher<[FavoriteEntity], ErrorType> {
        Just(entities).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }

    func isFavorite(hymnIdentifier: HymnIdentifier) -> AnyPublisher<Bool, ErrorType> {
        let isFavorite = !entities.filter { entity -> Bool in
            HymnIdentifier(entity.hymnIdentifierEntity) == hymnIdentifier
        }.isEmpty
        return Just(isFavorite).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }
}
#endif
