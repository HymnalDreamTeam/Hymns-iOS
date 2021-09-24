import Combine

import SwiftUI
import RealmSwift
import Resolver

// swiftlint:disable all
class Entity: Object {
    @objc dynamic var text: String!

    override required init() {
        super.init()
    }

    init(text: String) {
        super.init()
        self.text = text
    }

    override static func primaryKey() -> String? {
        return "text"
    }
}

class DataStore {
    private let realm: Realm
    init() {
        self.realm = try! Realm()
        try! realm.write {
            realm.add(Entity(text: "Entity 1"), update: .modified)
            realm.add(Entity(text: "Entity 2"), update: .modified)
            realm.add(Entity(text: "Entity 3"), update: .modified)
            realm.add(Entity(text: "Entity 4"), update: .modified)
        }
    }
    
    func getData() -> AnyPublisher<[Entity], Error> {
        realm.objects(Entity.self).collectionPublisher
            .map({ results -> [Entity] in
                results.map { entity -> Entity in
                    entity
                }
            }).eraseToAnyPublisher()
    }
    
    func storeData(entity: Entity) {
        try! realm.write {
            realm.add(entity, update: .modified)
        }
    }
}

class DetailViewModel: ObservableObject, Identifiable {

    @Published var text: String = ""

    init(text: String) {
        self.text = text
    }
}

class ContentViewModel: ObservableObject {

    private let dataStore: DataStore
    private let historyStore: HistoryStore
    private let mainQueue: DispatchQueue

    @Published var details = [DetailViewModel]()
    private var disposables = Set<AnyCancellable>()

    init(mainQueue: DispatchQueue = Resolver.resolve(name: "main"), historyStore: HistoryStore = Resolver.resolve()) {
        self.mainQueue = mainQueue
        self.historyStore = historyStore
        self.dataStore = DataStore()
    }
    
    func load() {
        dataStore.getData()
            .replaceError(with: [])
            .sink { entities in
                self.details = entities.map({ entity in
                    DetailViewModel(text: entity.text)
                })
                self.dataStore.storeData(entity: Entity(text: "new entity"))
            }.store(in: &disposables)
//        historyStore.recentSongs()
//            .replaceError(with: [])
//            .sink { recentSongs in
//                self.details = recentSongs.map({ recentSong in
//                    DetailViewModel(text: recentSong.songTitle)
//                })
//                self.historyStore.storeRecentSong(hymnToStore: HymnIdentifier(hymnType: .classic, hymnNumber: "34"), songTitle: "Detail 3")
//            }.store(in: &disposables)
    }
}

struct DetailView: View {

    @ObservedObject var viewModel: DetailViewModel

    var body: some View {
        ZStack {
            Text(viewModel.text)
        }
    }
}

struct ContentView: View {

    @ObservedObject private var viewModel = ContentViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.details) { detail in
                NavigationLink(destination: DetailView(viewModel: detail)) {
                    Text(detail.text)
                }
            }
        }.onAppear {
            viewModel.load()
        }
    }
}
