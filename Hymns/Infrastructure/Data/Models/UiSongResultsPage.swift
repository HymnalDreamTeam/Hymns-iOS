import Foundation

struct UiSongResultsPage: Equatable {
    let results: [UiSongResult]
    let hasMorePages: Bool?
}

struct UiSongResult: Equatable {
    let name: String?
    let identifiers: [HymnIdentifier]
}
