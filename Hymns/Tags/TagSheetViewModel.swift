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

    init(hymnToDisplay identifier: HymnIdentifier, tagStore: TagStore = Resolver.resolve(), hymnsRepository repository: HymnsRepository = Resolver.resolve(), mainQueue: DispatchQueue = Resolver.resolve(name: "main"), backgroundQueue: DispatchQueue = Resolver.resolve(name: "background")) {
        self.identifier = identifier
        self.tagStore = tagStore
        self.repository = repository
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
                    guard let self = self, let hymn = hymn, !hymn.lyrics.isEmpty else {
                        return
                    }
                    self.title = hymn.computedTitle
            }).store(in: &disposables)
    }

    func fetchTags() {
        tagStore.getTagsForHymn(hymnIdentifier: self.identifier)
            .map({ entities -> [UiTag] in
                entities.map { entity -> UiTag in
                    return UiTag(
                        title: entity.tag,
                        color: entity.tagColor)
                }}).replaceError(with: [UiTag]())
            .receive(on: mainQueue)
            .sink(receiveValue: { results in
                self.tags = results
            }).store(in: &disposables)
    }

    func addTag(tagTitle: String, tagColor: TagColor) {
        self.tagStore.storeTag(TagEntity(hymnIdentifier: self.identifier, songTitle: self.title, tag: tagTitle, tagColor: tagColor))
    }

    func deleteTag(tagTitle: String, tagColor: TagColor) {
        self.tagStore.deleteTag(primaryKey: TagEntity.createPrimaryKey(hymnIdentifier: self.identifier, tag: tagTitle), tag: tagTitle)
    }
}

class UiTag: Identifiable {

    let title: String
    let color: TagColor

    init(title: String, color: TagColor) {
        self.title = title
        self.color = color
    }
}

extension UiTag: Hashable {
    static func == (lhs: UiTag, rhs: UiTag) -> Bool {
        (lhs.title == rhs.title) && (lhs.color == rhs.color)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(color)
    }
}
