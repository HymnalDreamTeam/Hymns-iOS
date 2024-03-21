import Foundation
import Resolver
import SwiftUI

class SongResultViewModel: Identifiable {

    private let systemUtil: SystemUtil

    /// Unique string to identify a SongResultsViewModel. Two models with the same id are considered semantically the same.
    let stableId: String
    let title: String
    let label: String?
    let destinationView: AnyView

    init(stableId: String, title: String, label: String? = nil, destinationView: AnyView, systemUtil: SystemUtil = Resolver.resolve()) {
        self.stableId = stableId
        self.title = title
        self.label = label
        self.destinationView = destinationView
        self.systemUtil = systemUtil
    }

    func getVerticalPadding() -> CGFloat {
        return systemUtil.isIOS16Plus() ? 0 : 4
    }
}

extension SongResultViewModel: Hashable {
    static func == (lhs: SongResultViewModel, rhs: SongResultViewModel) -> Bool {
        lhs.stableId == rhs.stableId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(stableId)
    }
}

extension SongResultViewModel: CustomStringConvertible {
    var description: String {
        "\(stableId)|\(label ?? "")|\(title)"
    }
}
