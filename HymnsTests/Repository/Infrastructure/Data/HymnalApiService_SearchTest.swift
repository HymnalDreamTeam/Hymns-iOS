import Combine
import Nimble
import Resolver
import XCTest
@testable import Hymns

class HymnalApiService_SearchTest: XCTestCase {

    var protocolMock: URLProtocolMock!
    var target: HymnalApiServiceImpl!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        let session = URLSession(configuration: config)
        target = HymnalApiServiceImpl(decoder: Resolver.resolve(), session: session)
    }

    override func tearDown() {
        super.tearDown()
        URLProtocolMock.response = nil
        URLProtocolMock.error = nil
        URLProtocolMock.testURLs = [URL?: Data]()
    }

    func test_networkError() {

        // Stub mock to return a network error.
        URLProtocolMock.error = ErrorType.data(description: "network error!")

        let failure = XCTestExpectation(description: "failure received")
        let value = XCTestExpectation(description: "value received")
        value.isInverted = true

        let cancellable
            = target.search(for: "Drink", onPage: nil)
                .sink(receiveCompletion: { state in
                    failure.fulfill()
                    expect(state).to(equal(.failure(.data(description: "The operation couldn’t be completed. (NSURLErrorDomain error -1.)"))))
                }, receiveValue: { _ in
                    value.fulfill()
                    return
                })
        wait(for: [failure, value], timeout: testTimeout)
        cancellable.cancel()
    }

    func test_decodeError() {

        // Stub mock to return a valid network response but an invalid json.
        URLProtocolMock.testURLs = [Self.searchDrink: Data("".utf8)]
        URLProtocolMock.response = Self.createValidResponse(for: Self.searchDrink)

        let failure = XCTestExpectation(description: "failure received")
        let value = XCTestExpectation(description: "value received")
        value.isInverted = true

        let cancellable
            = target.search(for: "Drink", onPage: nil)
                .sink(receiveCompletion: { state in
                    failure.fulfill()
                    expect(state).to(equal(.failure(.parsing(description: "The data couldn’t be read because it isn’t in the correct format."))))
                }, receiveValue: { _ in
                    value.fulfill()
                })
        wait(for: [failure, value], timeout: testTimeout)
        cancellable.cancel()
    }

    func test_validResponse() {

        // Stub mock to return a valid network response but an invalid json.
        URLProtocolMock.testURLs = [Self.searchDrink: Data(search_drink_json.utf8)]
        URLProtocolMock.response = Self.createValidResponse(for: Self.searchDrink)

        let finished = XCTestExpectation(description: "finished received")
        let value = XCTestExpectation(description: "value received")

        let cancellable
            = target.search(for: "drink", onPage: nil)
                .sink(
                    receiveCompletion: { state in
                        finished.fulfill()
                        expect(state).to(equal(.finished))
                }, receiveValue: { resultPage in
                    value.fulfill()
                    expect(resultPage).to(equal(search_drink_song_result_page))
                })
        wait(for: [finished, value], timeout: testTimeout)
        cancellable.cancel()
    }

    func test_validResponse_onPage3() {

        // Stub mock to return a valid network response but an invalid json.
        URLProtocolMock.testURLs = [Self.searchDrinkPage3: Data(search_drink_page_3_json.utf8)]
        URLProtocolMock.response = Self.createValidResponse(for: Self.searchDrinkPage3)

        let finished = XCTestExpectation(description: "finished received")
        let value = XCTestExpectation(description: "value received")

        let cancellable
            = target.search(for: "drink", onPage: 3)
                .sink(
                    receiveCompletion: { state in
                        finished.fulfill()
                        expect(state).to(equal(.finished))
                }, receiveValue: { resultPage in
                    value.fulfill()
                    expect(resultPage).to(equal(search_drink_page_3_song_result_page))
                })
        wait(for: [finished, value], timeout: testTimeout)
        cancellable.cancel()
    }

    func test_validResponse_onPage10() {

        // Stub mock to return a valid network response but an invalid json.
        URLProtocolMock.testURLs = [Self.searchDrinkPage10: Data(search_drink_page_10_json.utf8)]
        URLProtocolMock.response = Self.createValidResponse(for: Self.searchDrinkPage10)

        let finished = XCTestExpectation(description: "finished received")
        let value = XCTestExpectation(description: "value received")

        let cancellable
            = target.search(for: "drink", onPage: 10)
                .sink(
                    receiveCompletion: { state in
                        finished.fulfill()
                        expect(state).to(equal(.finished))
                }, receiveValue: { resultPage in
                    value.fulfill()
                    expect(resultPage).to(equal(search_drink_page_10_song_result_page))
                })
        wait(for: [finished, value], timeout: testTimeout)
        cancellable.cancel()
    }
}

extension HymnalApiService_SearchTest {
    static let searchDrink = URL(string: "http://hymnalnetapi.herokuapp.com/v2/search/drink")!
    static let searchDrinkPage3 = URL(string: "http://hymnalnetapi.herokuapp.com/v2/search/drink/3")!
    static let searchDrinkPage10 = URL(string: "http://hymnalnetapi.herokuapp.com/v2/search/drink/10")!
}
