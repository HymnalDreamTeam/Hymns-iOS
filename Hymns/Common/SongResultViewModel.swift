import Foundation
import SwiftUI

class SongResultViewModel: Identifiable {

    /// Unique string to identify a SongResultsViewModel. Two models with the same id are considered semantically the same.
    let stableId: String
    let title: String
    let label: String?
    let destinationView: AnyView

    init(stableId: String, title: String, label: String? = nil, destinationView: AnyView) {
        self.stableId = stableId
        self.title = title
        self.label = label
        self.destinationView = destinationView
    }
}

extension SongResultViewModel: Hashable {
    static func == (lhs: SongResultViewModel, rhs: SongResultViewModel) -> Bool {
        lhs.stableId == rhs.stableId && lhs.title == rhs.title && lhs.label == rhs.label
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(stableId)
        hasher.combine(title)
        hasher.combine(label)
    }
}

extension SongResultViewModel: CustomStringConvertible {
    var description: String {
        "\(stableId): \(label ?? "") \(title)"
    }
}
