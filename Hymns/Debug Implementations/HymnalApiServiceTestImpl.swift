#if DEBUG
import Combine
import Foundation

class HymnalApiServiceTestImpl: HymnalApiService {

    private var hymnStore = [classic1151: classic1151Entity, chineseSupplement216: chineseSupplement216Entity, classic2: classic2Entity]

    func getHymn(_ hymnIdentifier: HymnIdentifier) -> AnyPublisher<Hymn, ErrorType> {
        Just(Hymn(title: "throw an error", metaData: [], lyrics: [])).tryMap({ _ -> Hymn in
            throw URLError(.badServerResponse)
        }).mapError({ _ -> ErrorType in
            .data(description: "Forced error")
        }).eraseToAnyPublisher()
    }

    func search(for searchInput: String, onPage pageNumber: Int?) -> AnyPublisher<SongResultsPage, ErrorType> {
        Just(SongResultsPage(results: [], hasMorePages: false)).tryMap({ _ -> SongResultsPage in
            throw URLError(.badServerResponse)
        }).mapError({ _ -> ErrorType in
            .data(description: "Forced error")
        }).eraseToAnyPublisher()
    }
}
#endif
