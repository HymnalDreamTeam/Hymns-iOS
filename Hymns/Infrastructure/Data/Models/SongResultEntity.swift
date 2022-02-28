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
        // Many hymn titles prepend "Hymn: " to the title. It is unnecessary and takes up screen space, so  we
        // strip it out whenever possible.
        title = try container.decode(String.self, forKey: .title).replacingOccurrences(of: "Hymn: ", with: "")
    }
}

struct SongbaseResultEntity: Decodable {
    let bookId: Int
    let bookIndex: Int
    let title: String

    enum CodingKeys: String, CodingKey {
        case bookId = "book_id"
        case bookIndex = "book_index"
        case title = "title"
    }
}

extension SongbaseResultEntity: FetchableRecord {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bookId = try container.decode(Int.self, forKey: .bookId)
        bookIndex = try container.decode(Int.self, forKey: .bookIndex)
        title = try container.decode(String.self, forKey: .title)
    }
}

extension SongbaseResultEntity: Equatable {
    static func == (lhs: SongbaseResultEntity, rhs: SongbaseResultEntity) -> Bool {
        return lhs.bookId == rhs.bookId && lhs.bookIndex == rhs.bookIndex
    }
}
