import Foundation
import Resolver
import SwiftUI

enum SongResultViewModel {
    case single(SingleSongResultViewModel)
    case multi(MultiSongResultViewModel)

    var stableId: AnyHashable {
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

    func overlaps(with other: SongResultViewModel) -> Bool {
        if let selfSingle = self.singleSongResultViewModel, let otherSingle = other.singleSongResultViewModel {
            return selfSingle.overlaps(with: otherSingle)
        }

        if let selfMulti = self.multiSongResultViewModel, let otherMulti = other.multiSongResultViewModel {
            return selfMulti.overlaps(with: otherMulti)
        }
        return false
    }

    func merge(with other: SongResultViewModel) -> SongResultViewModel? {
        if let selfSingle = self.singleSongResultViewModel, let otherSingle = other.singleSongResultViewModel {
            return .single(selfSingle.merge(with: otherSingle))
        }

        if let selfMulti = self.multiSongResultViewModel, let otherMulti = other.multiSongResultViewModel {
            return .multi(selfMulti.merge(with: otherMulti))
        }
        return nil
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

    let stableId: HymnIdentifier
    let title: String
    let label: String?
    let destinationView: AnyView

    init(stableId: HymnIdentifier, title: String, label: String? = nil, destinationView: AnyView,
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

    func overlaps(with other: SingleSongResultViewModel) -> Bool {
        return stableId == other.stableId
    }

    func merge(with other: SingleSongResultViewModel) -> SingleSongResultViewModel {
        // Nothing to merge, so just return itself.
        return self
    }
}

extension SingleSongResultViewModel: CustomStringConvertible {
    var description: String {
        "\(stableId)|\(label ?? "")|\(title)"
    }
}

class MultiSongResultViewModel: Identifiable {

    private let systemUtil: SystemUtil

    let stableId: [HymnIdentifier]
    let title: String
    let labels: [String]?
    let destinationView: AnyView

    init(stableId: [HymnIdentifier], title: String, labels: [String]? = nil, destinationView: AnyView,
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

    func overlaps(with other: MultiSongResultViewModel) -> Bool {
        !Set(self.stableId).isDisjoint(with: (Set(other.stableId)))
    }

    func merge(with other: MultiSongResultViewModel) -> MultiSongResultViewModel {
        var newStableId = stableId
        newStableId.append(contentsOf: other.stableId.filter({ stableId -> Bool in
            !newStableId.contains(stableId)
        }))
        return MultiSongResultViewModel(stableId: newStableId, title: title, destinationView: destinationView)
    }
}

extension MultiSongResultViewModel: CustomStringConvertible {
    var description: String {
        "\(stableId)|\(String(describing: labels))|\(title)"
    }
}
