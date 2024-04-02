import Foundation

/// Set of common transformations that are performed in many places.
class Transformers: ObservableObject {

    static func toSongResultsViewModel(entity: SongResultEntity, storeInHistoryStore: Bool = false) -> SongResultViewModel {
        let hymnIdentifier = HymnIdentifier(hymnType: entity.hymnType, hymnNumber: entity.hymnNumber)
        let stableId = String(describing: hymnIdentifier)
        let destination =
        DisplayHymnContainerView(
            viewModel: DisplayHymnContainerViewModel(hymnToDisplay: hymnIdentifier, storeInHistoryStore: storeInHistoryStore)).eraseToAnyView()
        if let title = entity.title {
            return SongResultViewModel(stableId: stableId, title: title,
                                       label: hymnIdentifier.displayTitle,
                                       destinationView: destination)
        } else {
            return SongResultViewModel(stableId: stableId, title: hymnIdentifier.displayTitle,
                                       destinationView: destination)
        }
    }
}
