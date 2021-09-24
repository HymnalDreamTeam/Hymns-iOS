import Foundation
import SwiftEventBus

class DisplayHymnContainerViewModel: ObservableObject {

    static let songSwipableEvent = "songSwipableEvent"

    @Published var hymns: [DisplayHymnViewModel]?
    @Published var currentHymn: Int = 0
    @Published var swipeEnabled = true

    private let identifier: HymnIdentifier
    private let storeInHistoryStore: Bool

    init(hymnToDisplay identifier: HymnIdentifier, storeInHistoryStore: Bool = false) {
        self.identifier = identifier
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
        let hymnNumber = identifier.hymnNumber
        let queryParams = identifier.queryParams

        if hymnType.maxNumber > 0 && hymnNumber.isPositiveInteger, let hymnNumberInt = hymnNumber.toInteger, hymnNumberInt <= hymnType.maxNumber {
            hymns = (1...HymnType.classic.maxNumber).map({ num -> DisplayHymnViewModel in
                let numString = String(num)
                let shouldStore = storeInHistoryStore && hymnNumber == numString
                return DisplayHymnViewModel(hymnToDisplay: HymnIdentifier(hymnType: hymnType, hymnNumber: numString, queryParams: queryParams),
                                            storeInHistoryStore: shouldStore)
            })
            currentHymn = hymnNumberInt - 1
        } else {
            hymns = [DisplayHymnViewModel(hymnToDisplay: identifier, storeInHistoryStore: storeInHistoryStore)]
            currentHymn = 0
        }
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
