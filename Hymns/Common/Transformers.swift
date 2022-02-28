import Foundation

/// Set of common transformations that are performed in many places.
class Transformers: ObservableObject {

    static func toSongResultsViewModel(entity: SongResultEntity, storeInHistoryStore: Bool = false) -> SongResultViewModel {
        let hymnIdentifier = HymnIdentifier(hymnType: entity.hymnType, hymnNumber: entity.hymnNumber, queryParams: entity.queryParams)
        let stableId = String(describing: hymnIdentifier)
        let title = entity.title
        let label = String(format: hymnIdentifier.hymnType.displayLabel, hymnIdentifier.hymnNumber)
        let destination =
        DisplayHymnContainerView(
            viewModel: DisplayHymnContainerViewModel(hymnToDisplay: hymnIdentifier, storeInHistoryStore: storeInHistoryStore)).eraseToAnyView()
        return SongResultViewModel(stableId: stableId, title: title, label: label, destinationView: destination)
    }
}
