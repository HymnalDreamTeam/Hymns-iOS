import Foundation
import Resolver
import SwiftUI

enum SongResultViewModel {
    case single(SingleSongResultViewModel)
    case multi(MultiSongResultViewModel)

    var stableId: String {
        switch self {
        case .single(let viewModel):
            return viewModel.stableId
        case .multi(let viewModel):
            return viewModel.stableId
        }
    }

    var destinationView: AnyView {
        switch self {
        case .single(let viewModel):
            return viewModel.destinationView
        case .multi(let viewModel):
            return viewModel.destinationView
        }
    }

    var singleSongResultViewModel: SingleSongResultViewModel? {
        switch self {
        case .single(let viewModel):
            return viewModel
        default:
            return nil
        }
    }

    var multiSongResultViewModel: MultiSongResultViewModel? {
        switch self {
        case .multi(let viewModel):
            return viewModel
        default:
            return nil
        }
    }
}

extension SongResultViewModel: Hashable, Equatable {
    static func == (lhs: SongResultViewModel, rhs: SongResultViewModel) -> Bool {
        switch (lhs, rhs) {
        case let (.single(lhsViewModel), .single(rhsViewModel)):
            return lhsViewModel == rhsViewModel
        case let (.multi(lhsViewModel), .multi(rhsViewModel)):
            return lhsViewModel == rhsViewModel
        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .single(let viewModel):
            viewModel.hash(into: &hasher)
        case .multi(let viewModel):
            viewModel.hash(into: &hasher)
        }
    }
}

class SingleSongResultViewModel: Identifiable {

    private let systemUtil: SystemUtil

    /// Unique string to identify a SongResultsViewModel. Two models with the same id are considered semantically the same.
    let stableId: String
    let title: String
    let label: String?
    let destinationView: AnyView

    init(stableId: String, title: String, label: String? = nil, destinationView: AnyView,
         systemUtil: SystemUtil = Resolver.resolve()) {
        self.stableId = stableId
        self.title = title
        self.label = label
        self.destinationView = destinationView
        self.systemUtil = systemUtil
    }
}

extension SingleSongResultViewModel: Hashable {
    static func == (lhs: SingleSongResultViewModel, rhs: SingleSongResultViewModel) -> Bool {
        lhs.stableId == rhs.stableId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(stableId)
    }
}

extension SingleSongResultViewModel: CustomStringConvertible {
    var description: String {
        "\(stableId)|\(label ?? "")|\(title)"
    }
}

class MultiSongResultViewModel: Identifiable {

    private let systemUtil: SystemUtil

    /// Unique string to identify a SongResultsViewModel. Two models with the same id are considered semantically the same.
    let stableId: String
    let title: String
    let labels: [String]?
    let destinationView: AnyView

    init(stableId: String, title: String, labels: [String]? = nil, destinationView: AnyView,
         systemUtil: SystemUtil = Resolver.resolve()) {
        self.stableId = stableId
        self.title = title
        self.labels = labels
        self.destinationView = destinationView
        self.systemUtil = systemUtil
    }
}

extension MultiSongResultViewModel: Hashable {
    static func == (lhs: MultiSongResultViewModel, rhs: MultiSongResultViewModel) -> Bool {
        lhs.stableId == rhs.stableId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(stableId)
    }
}

extension MultiSongResultViewModel: CustomStringConvertible {
    var description: String {
        "\(stableId)|\(String(describing: labels))|\(title)"
    }
}
