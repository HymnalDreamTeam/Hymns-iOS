import Foundation
import GRDB

struct SearchResultEntity: Decodable {
    let hymnType: HymnType
    let hymnNumber: String
    let queryParams: [String: String]?
    let title: String
    let matchInfo: Data

    enum CodingKeys: String, CodingKey {
        case hymnType = "HYMN_TYPE"
        case hymnNumber = "HYMN_NUMBER"
        case queryParams = "QUERY_PARAMS"
        case title = "SONG_TITLE"
        case matchInfo = "matchinfo(SEARCH_VIRTUAL_SONG_DATA, 's')"
    }
}

extension SearchResultEntity: FetchableRecord {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hymnType = try container.decode(HymnType.self, forKey: .hymnType)
        hymnNumber = try container.decode(String.self, forKey: .hymnNumber)
        queryParams = try container.decode(String.self, forKey: .queryParams).deserializeFromQueryParamString
        // Many hymn titles prepend "Hymn: " to the title. It is unnecessary and takes up screen space, so  we
        // strip it out whenever possible.
        title = try container.decode(String.self, forKey: .title).replacingOccurrences(of: "Hymn: ", with: "")
        matchInfo = try container.decode(Data.self, forKey: .matchInfo)
    }
}
