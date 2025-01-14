#if DEBUG
import Combine
import Foundation

class TagStoreTestImpl: TagStore {

    var tags = [Tag(hymnIdentifier: classic1151.hymnIdentifier!, songTitle: "Click me!", tag: "tag1", color: .green),
                Tag(hymnIdentifier: classic40.hymnIdentifier!, songTitle: "Don't click me!", tag: "tag1", color: .green),
                Tag(hymnIdentifier: classic40.hymnIdentifier!, songTitle: "Should not be dhown", tag: "tag2", color: .red)]

    func storeTag(_ tag: Tag) {
        tags.append(tag)
    }

    func storeTagEntity(_ tag: TagEntity) {
        tags.append(tag.tagObject)
    }

    func deleteTag(_ tag: Tag) {
        tags.removeAll { storedTag -> Bool in
            storedTag == tag
        }
    }

    func getAllTagEntities() -> AnyPublisher<[TagEntity], ErrorType> {
        Just(tags).map { tags in
            tags.map { tag in
                TagEntity(tagObject: tag, created: Date.now)
            }
        }.mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }

    func getSongsByTag(_ tag: UiTag) -> AnyPublisher<[SongResultEntity], ErrorType> {
        let matchingTags = tags.compactMap { storedTag -> SongResultEntity? in
            guard storedTag.tag == tag.title && storedTag.color == tag.color else {
                return nil
            }
            let hymnType = storedTag.hymnIdentifier.hymnType
            let hymnNumber = storedTag.hymnIdentifier.hymnNumber
            return SongResultEntity(hymnType: hymnType, hymnNumber: hymnNumber, title: storedTag.songTitle)
        }
        return Just(matchingTags).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }

    func getTagsForHymn(hymnIdentifier: HymnIdentifier) -> AnyPublisher<[Tag], ErrorType> {
        Just([Tag]()).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }

    func getUniqueTags() -> AnyPublisher<[UiTag], ErrorType> {
        let uiTags = [UiTag]()
        return Just(tags.reduce(into: uiTags) { uiTags, tag in
            let uiTag = UiTag(title: tag.tag, color: tag.color)
            if !uiTags.contains(uiTag) {
                uiTags.append(uiTag)
            }
        }).mapError({ _ -> ErrorType in
            // This will never be triggered.
        }).eraseToAnyPublisher()
    }

    func clear() {
        tags.removeAll()
    }
}
#endif
