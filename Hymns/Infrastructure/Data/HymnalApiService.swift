import Combine
import Foundation
import Resolver

/**
 * Service to contact the Hymnal API.
 */
protocol HymnalApiService {
    func getHymn(_ hymnIdentifier: HymnIdentifier) -> AnyPublisher<Hymn, ErrorType>
    func search(for searchInput: String, onPage pageNumber: Int?) -> AnyPublisher<SongResultsPage, ErrorType>
}

class HymnalApiServiceImpl: HymnalApiService {

    private let decoder: JSONDecoder
    private let session: URLSession

    init(decoder: JSONDecoder = Resolver.resolve(), session: URLSession = Resolver.resolve()) {
        self.decoder = decoder
        self.session = session
    }

    func getHymn(_ hymnIdentifier: HymnIdentifier) -> AnyPublisher<Hymn, ErrorType> {
        let hymnType = hymnIdentifier.hymnType
        let hymnNumber = hymnIdentifier.hymnNumber
        let queryParams = hymnIdentifier.queryParams

        guard let url = HymnalApi.getHymnUrl(hymnType: hymnType, hymnNumber: hymnNumber, queryParams: queryParams) else {
            let hymnIdentifier = queryParams != nil
                ? HymnIdentifier(hymnType: hymnType, hymnNumber: hymnNumber, queryParams: queryParams!)
                : HymnIdentifier(hymnType: hymnType, hymnNumber: hymnNumber)
            let error = ErrorType.data(description: "Couldn't create sarch URL for \(hymnIdentifier)")
            return Fail(error: error).eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { error in
                .data(description: error.localizedDescription)
            }
            .flatMap(maxPublishers: .max(1)) { pair in
                Just(pair.data)
                    .decode(type: Hymn.self, decoder: self.decoder)
                    .mapError { error in
                        .parsing(description: error.localizedDescription)
                    }.eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }

    func search(for searchInput: String, onPage pageNumber: Int?) -> AnyPublisher<SongResultsPage, ErrorType> {
        guard let url = HymnalApi.searchUrl(for: searchInput, onPage: pageNumber) else {
            let error = ErrorType.data(description: "Couldn't create sarch URL for \(searchInput) on page \(String(describing: pageNumber))")
            return Fail(error: error).eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { error in
                .data(description: error.localizedDescription)
            }
            .flatMap(maxPublishers: .max(1)) { pair in
                Just(pair.data)
                    .decode(type: SongResultsPage.self, decoder: self.decoder)
                    .mapError { error in
                        .parsing(description: error.localizedDescription)
                }.eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
}

extension Resolver {
    static func registerHymnalApiService() {
        register {HymnalApiServiceImpl() as HymnalApiService}.scope(.application)
    }
}

private struct HymnalApi {
    private static let scheme = "http"
    private static let host = "hymnalnetapi.herokuapp.com"
}

private extension HymnalApi {
    static func getHymnUrl(hymnType: HymnType, hymnNumber: String, queryParams: [String: String]?) -> URL? {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = Self.host
        components.path = "/v2/hymn/\(hymnType.abbreviatedValue)/\(hymnNumber)"
        if let queryParams = queryParams, !queryParams.isEmpty {
            components.queryItems = queryParams.compactMap({ (key, value) -> URLQueryItem in
                return URLQueryItem(name: key, value: value)
            })
        }
        return components.url
    }

    static func searchUrl(for searchInput: String, onPage pageNumber: Int?) -> URL? {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = Self.host
        if let pageNumber = pageNumber {
            components.path = "/v2/search/\(searchInput)/\(pageNumber)"
        } else {
            components.path = "/v2/search/\(searchInput)"
        }
        return components.url
    }
}
