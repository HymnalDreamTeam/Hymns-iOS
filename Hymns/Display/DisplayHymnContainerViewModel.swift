import Combine
import Foundation
import Resolver
import SwiftEventBus

class DisplayHymnContainerViewModel: ObservableObject {

    static let songSwipableEvent = "songSwipableEvent"

    @Published var hymns: [DisplayHymnViewModel]?
    @Published var swipeEnabled = true

    var currentHymn: Int = 0
    private let backgroundQueue: DispatchQueue
    private let dataStore: HymnDataStore
    private let identifier: HymnIdentifier
    private let mainQueue: DispatchQueue
    private let storeInHistoryStore: Bool

    private var disposables = Set<AnyCancellable>()

    init(hymnToDisplay identifier: HymnIdentifier, storeInHistoryStore: Bool = false,
         backgroundQueue: DispatchQueue = Resolver.resolve(name: "background"),
         dataStore: HymnDataStore = Resolver.resolve(),
         mainQueue: DispatchQueue = Resolver.resolve(name: "main")) {
        self.backgroundQueue = backgroundQueue
        self.dataStore = dataStore
        self.identifier = identifier
        self.mainQueue = mainQueue
        self.storeInHistoryStore = storeInHistoryStore
        SwiftEventBus.onMainThread(self, name: Self.songSwipableEvent, handler: { result in
            if let enableSwiping = result?.object as? Bool {
                self.swipeEnabled = enableSwiping
            }
        })
    }

    deinit {
        SwiftEventBus.unregister(self)
    }

    func populateHymns() {
        let hymnType = identifier.hymnType
        dataStore.getHymnNumbers(by: hymnType)
            .subscribe(on: backgroundQueue)
            .replaceError(with: [String]())
            .map { hymnNumbers in
                hymnNumbers
                    .filter({ hymnNumber in
                        hymnNumber.isPositiveInteger
                    }).compactMap({ hymnNumber in
                        hymnNumber.toInteger
                    }).sorted().map({ hymnNumber in
                        String(hymnNumber)
                    }).map { hymnNumber in
                        HymnIdentifier(hymnType: hymnType, hymnNumber: hymnNumber)
                    }
            }.sink { hymnIdentifiers in
                if let index = hymnIdentifiers.firstIndex(of: self.identifier) {
                    self.hymns = hymnIdentifiers.map({ hymnIdentifier in
                        DisplayHymnViewModel(hymnToDisplay: hymnIdentifier, storeInHistoryStore: self.storeInHistoryStore && self.identifier == hymnIdentifier)
                    })
                    self.currentHymn = index
                } else {
                    self.hymns = [DisplayHymnViewModel(hymnToDisplay: self.identifier, storeInHistoryStore: self.storeInHistoryStore)]
                    self.currentHymn = 0
                }
            }.store(in: &disposables)
    }
}

extension DisplayHymnContainerViewModel: Hashable {
    static func == (lhs: DisplayHymnContainerViewModel, rhs: DisplayHymnContainerViewModel) -> Bool {
        lhs.identifier == rhs.identifier && lhs.storeInHistoryStore == rhs.storeInHistoryStore
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(storeInHistoryStore)
    }
}
