import Combine
import Resolver
import SwiftUI

class SongInfoViewModel: ObservableObject {

    @Published var type: SongInfoType
    @Published var values: [String]

    init(type: SongInfoType, values: [String]) {
        self.type = type
        self.values = values
    }

    func createSongInfoItem(_ value: String) -> BrowseResultsListViewModel {
        switch type {
        case .category:
            return BrowseResultsListViewModel(category: value)
        case .subcategory:
            return BrowseResultsListViewModel(subcategory: value)
        case .author:
            return BrowseResultsListViewModel(author: value)
        case .composer:
            return BrowseResultsListViewModel(composer: value)
        case .key:
            return BrowseResultsListViewModel(key: value)
        case .time:
            return BrowseResultsListViewModel(time: value)
        case .meter:
            return BrowseResultsListViewModel(meter: value)
        case .scriptures:
            return BrowseResultsListViewModel(scriptures: value)
        case .hymnCode:
            return BrowseResultsListViewModel(hymnCode: value)
        }
    }
}

extension SongInfoViewModel: Hashable, Equatable {
    static func == (lhs: SongInfoViewModel, rhs: SongInfoViewModel) -> Bool {
        lhs.type.label == rhs.type.label && lhs.values == rhs.values
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type.label)
        hasher.combine(values)
    }
}

extension SongInfoViewModel: CustomStringConvertible {
    var description: String { "\(type.label): \(values)" }
}

enum SongInfoType {
    case category
    case subcategory
    case author
    case composer
    case key
    case time
    case meter
    case scriptures
    case hymnCode

    var label: String {
        switch self {
        case .category:
            return NSLocalizedString("Category", comment: "Song info label for 'Category'.")
        case .subcategory:
            return NSLocalizedString("Subcategory", comment: "Song info label for 'Subcategory'.")
        case .author:
            return NSLocalizedString("Author", comment: "Song info label for 'Author'.")
        case .composer:
            return NSLocalizedString("Composer", comment: "Song info label for 'Composer'.")
        case .key:
            return NSLocalizedString("Key", comment: "Song info label for 'Key'.")
        case .time:
            return NSLocalizedString("Time", comment: "Song info label for 'Time'.")
        case .meter:
            return NSLocalizedString("Meter", comment: "Song info label for 'Meter'.")
        case .scriptures:
            return NSLocalizedString("Scriptures", comment: "Song info label for 'Scriptures'.")
        case .hymnCode:
            return NSLocalizedString("Hymn Code", comment: "Song info label for 'Hymn Code'.")
        }
    }
}
