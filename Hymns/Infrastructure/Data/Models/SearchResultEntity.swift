import Foundation
import GRDB

struct SearchResultEntity: Decodable {
    let hymnType: HymnType
    let hymnNumber: String
    let title: String?
    let matchInfo: Data
    let songId: Int

    enum CodingKeys: String, CodingKey {
        case hymnType = "HYMN_TYPE"
        case hymnNumber = "HYMN_NUMBER"
        case title = "SONG_TITLE"
        case matchInfo = "matchinfo(SEARCH_VIRTUAL_SONG_DATA, 's')"
        case songId = "ID"
    }
}

extension SearchResultEntity: FetchableRecord {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hymnType = try container.decode(HymnType.self, forKey: .hymnType)
        hymnNumber = try container.decode(String.self, forKey: .hymnNumber)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        matchInfo = try container.decode(Data.self, forKey: .matchInfo)
        songId = try container.decode(Int.self, forKey: .songId)
    }
}

struct SongbaseSearchResultEntity: Decodable {
    let bookId: Int
    let bookIndex: Int
    let title: String
    let matchInfo: Data

    enum CodingKeys: String, CodingKey {
        case bookId = "book_id"
        case bookIndex = "book_index"
        case title = "title"
        case matchInfo = "matchinfo(songs_virtual, 's')"
    }
}

extension SongbaseSearchResultEntity: FetchableRecord {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bookId = try container.decode(Int.self, forKey: .bookId)
        bookIndex = try container.decode(Int.self, forKey: .bookIndex)
        title = try container.decode(String.self, forKey: .title)
        matchInfo = try container.decode(Data.self, forKey: .matchInfo)
    }
}
