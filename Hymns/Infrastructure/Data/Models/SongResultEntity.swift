import Foundation
import GRDB

struct SongResultEntity: Decodable, Equatable {
    let hymnType: HymnType
    let hymnNumber: String
    let title: String?

    init(hymnType: HymnType, hymnNumber: String, title: String? = nil) {
        self.hymnType = hymnType
        self.hymnNumber = hymnNumber
        self.title = title
    }

    enum CodingKeys: String, CodingKey {
        case hymnType = "HYMN_TYPE"
        case hymnNumber = "HYMN_NUMBER"
        case title = "SONG_TITLE"
    }
}

extension SongResultEntity: FetchableRecord {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hymnType = try container.decode(HymnType.self, forKey: .hymnType)
        hymnNumber = try container.decode(String.self, forKey: .hymnNumber)
        title = try container.decodeIfPresent(String.self, forKey: .title)
    }
}
