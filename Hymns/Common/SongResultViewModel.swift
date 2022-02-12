import Foundation
import SwiftUI

class SongResultViewModel: Identifiable {

    /// Unique string to identify a SongResultsViewModel. Two models with the same id are considered semantically the same.
    let stableId: String
    let title: String
    let destinationView: AnyView

    init(stableId: String, title: String, destinationView: AnyView) {
        self.stableId = stableId
        self.title = title
        self.destinationView = destinationView
    }
}

extension SongResultViewModel: Hashable {
    static func == (lhs: SongResultViewModel, rhs: SongResultViewModel) -> Bool {
        lhs.stableId == rhs.stableId && lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(stableId)
        hasher.combine(title)
    }
}

extension SongResultViewModel: CustomStringConvertible {
    var description: String {
        "\(stableId): \(title)"
    }
}
