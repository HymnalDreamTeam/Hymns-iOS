import Foundation
import GRDB

struct SongResultEntity: Decodable, Equatable {
    let hymnType: HymnType
    let hymnNumber: String
    let queryParams: [String: String]?
    let title: String

    enum CodingKeys: String, CodingKey {
        case hymnType = "HYMN_TYPE"
        case hymnNumber = "HYMN_NUMBER"
        case queryParams = "QUERY_PARAMS"
        case title = "SONG_TITLE"
    }
}

extension SongResultEntity: FetchableRecord {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hymnType = try container.decode(HymnType.self, forKey: .hymnType)
        hymnNumber = try container.decode(String.self, forKey: .hymnNumber)
        queryParams = try container.decode(String.self, forKey: .queryParams).deserializeFromQueryParamString
        title = try container.decode(String.self, forKey: .title)
    }
}
