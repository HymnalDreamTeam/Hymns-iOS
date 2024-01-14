import Combine
import SwiftUI
import RealmSwift
import Resolver

class TagSheetViewModel: ObservableObject {

    typealias Title = String
    @Published var tags = [UiTag]()
    @Published var title: String = ""

    let tagStore: TagStore
    let identifier: HymnIdentifier
    private let backgroundQueue: DispatchQueue
    private let mainQueue: DispatchQueue
    private let repository: HymnsRepository
    private var disposables = Set<AnyCancellable>()

    init(hymnToDisplay identifier: HymnIdentifier,
         tagStore: TagStore = Resolver.resolve(),
         hymnsRepository: HymnsRepository = Resolver.resolve(),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main"),
         backgroundQueue: DispatchQueue = Resolver.resolve(name: "background")) {
        self.identifier = identifier
        self.tagStore = tagStore
        self.repository = hymnsRepository
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
    }

    func fetchHymn() {
        repository
            .getHymn(identifier)
            .subscribe(on: backgroundQueue)
            .receive(on: mainQueue)
            .sink(
                receiveValue: { [weak self] hymn in
                    guard let self = self, let hymn = hymn else {
                        return
                    }
                    self.title = hymn.title ?? identifier.displayTitle
            }).store(in: &disposables)
    }

    func fetchTags() {
        tagStore.getTagsForHymn(hymnIdentifier: self.identifier)
            .map({ entities -> [UiTag] in
                entities.map { entity -> UiTag in
                    return UiTag(
                        title: entity.tag,
                        color: entity.color)
                }}).replaceError(with: [UiTag]())
            .receive(on: mainQueue)
            .sink(receiveValue: { results in
                self.tags = results
            }).store(in: &disposables)
    }

    func addTag(tagTitle: String, tagColor: TagColor) {
        let tag = Tag(hymnIdentifier: self.identifier, songTitle: self.title, tag: tagTitle, color: tagColor)
        self.tagStore.storeTag(tag)
    }

    func deleteTag(tagTitle: String, tagColor: TagColor) {
        let tag = Tag(hymnIdentifier: self.identifier, songTitle: self.title, tag: tagTitle, color: tagColor)
        self.tagStore.deleteTag(tag)
    }
}
