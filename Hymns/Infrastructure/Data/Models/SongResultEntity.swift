import Foundation
import GRDB

struct SongResultEntity: Decodable, Equatable {
    let hymnType: HymnType
    let hymnNumber: String
    let title: String?
    let songId: Int64?

    var hymnIdentifier: HymnIdentifier {
        HymnIdentifier(hymnType: hymnType, hymnNumber: hymnNumber)
    }

    init(hymnType: HymnType, hymnNumber: String, title: String? = nil, songId: Int64? = nil) {
        self.hymnType = hymnType
        self.hymnNumber = hymnNumber
        self.title = title
        self.songId = songId
    }

    init(hymnIdentifier: HymnIdentifier, title: String? = nil) {
        self.init(hymnType: hymnIdentifier.hymnType, hymnNumber: hymnIdentifier.hymnNumber, title: title)
    }

    enum CodingKeys: String, CodingKey {
        case hymnType = "HYMN_TYPE"
        case hymnNumber = "HYMN_NUMBER"
        case title = "SONG_TITLE"
        case id = "ID"
    }
}

extension SongResultEntity: FetchableRecord {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hymnType = try container.decode(HymnType.self, forKey: .hymnType)
        hymnNumber = try container.decode(String.self, forKey: .hymnNumber)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        songId = try container.decodeIfPresent(Int64.self, forKey: .id)
    }
}
