import Foundation
import Combine
import RealmSwift
import Resolver
import SwiftUI

class SongInfoDialogViewModel: ObservableObject {

    @Published var songInfo = [SongInfoViewModel]()

    private let identifier: HymnIdentifier
    private let hymn: UiHymn

    private var disposables = Set<AnyCancellable>()

    init?(hymnToDisplay identifier: HymnIdentifier, hymn: UiHymn) {
        self.identifier = identifier
        self.hymn = hymn
        self.songInfo = createSongInfo(hymn: hymn)

        if self.songInfo.isEmpty {
            return nil
        }
    }

    private func createSongInfo(hymn: UiHymn) -> [SongInfoViewModel] {
        var songInfo = [SongInfoViewModel]()

        if let category = hymn.category, !category.isEmpty {
            songInfo.append(createSongInfoViewModel(type: .category, compositeValue: category))
        }
        if let subcategory = hymn.subcategory, !subcategory.isEmpty {
            songInfo.append(createSongInfoViewModel(type: .subcategory, compositeValue: subcategory))
        }
        if let author = hymn.author, !author.isEmpty {
            songInfo.append(createSongInfoViewModel(type: .author, compositeValue: author))
        }
        if let composer = hymn.composer, !composer.isEmpty {
            songInfo.append(createSongInfoViewModel(type: .composer, compositeValue: composer))
        }
        if let key = hymn.key, !key.isEmpty {
            songInfo.append(createSongInfoViewModel(type: .key, compositeValue: key))
        }
        if let time = hymn.time, !time.isEmpty {
            songInfo.append(createSongInfoViewModel(type: .time, compositeValue: time))
        }
        if let meter = hymn.meter, !meter.isEmpty {
            songInfo.append(createSongInfoViewModel(type: .meter, compositeValue: meter))
        }
        if let scriptures = hymn.scriptures, !scriptures.isEmpty {
            songInfo.append(createSongInfoViewModel(type: .scriptures, compositeValue: scriptures))
        }
        if let hymnCode = hymn.hymnCode, !hymnCode.isEmpty {
            songInfo.append(createSongInfoViewModel(type: .hymnCode, compositeValue: hymnCode))
        }
        return songInfo
    }

    private func createSongInfoViewModel(type: SongInfoType, compositeValue: String) -> SongInfoViewModel {
        let values = compositeValue.components(separatedBy: ";").compactMap { value -> String? in
            guard !value.trim().isEmpty else {
                return nil
            }
            return value.trim()
        }
        return SongInfoViewModel(type: type, values: values)
    }
}

extension SongInfoDialogViewModel: Hashable {
    static func == (lhs: SongInfoDialogViewModel, rhs: SongInfoDialogViewModel) -> Bool {
        lhs.identifier == rhs.identifier
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
