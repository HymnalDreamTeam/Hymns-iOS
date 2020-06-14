import Combine
import Quick
import Mockingbird
import Nimble
import Resolver
@testable import Hymns

class HymnalApiService_GetHymnSpec: QuickSpec {

    override func spec() {
        describe("HymnalApi_GetHymnSpec") {
            var target: HymnalApiServiceImpl!
            beforeEach {
                let config = URLSessionConfiguration.ephemeral
                config.protocolClasses = [URLProtocolMock.self]
                let session = URLSession(configuration: config)
                target = HymnalApiServiceImpl(decoder: Resolver.resolve(), session: session)
            }
            afterEach {
                URLProtocolMock.response = nil
                URLProtocolMock.error = nil
                URLProtocolMock.testURLs = [URL?: Data]()
                URLSessionConfiguration.ephemeral.protocolClasses = nil
            }
            context("with network error") {
                beforeEach {
                    // Stub mock to return a network error.
                    URLProtocolMock.error = ErrorType.data(description: "network error!")
                }
                it("only the failure completion callback should be triggered") {
                    let failure = XCTestExpectation(description: "failure received")
                    let value = XCTestExpectation(description: "value received")
                    value.isInverted = true

                    let cancellable
                        = target.getHymn(children24)
                            .sink(receiveCompletion: { state in
                                failure.fulfill()
                                expect(state).to(equal(.failure(.data(description: "The operation couldn’t be completed. (NSURLErrorDomain error -1.)"))))
                            }, receiveValue: { _ in
                                value.fulfill()
                                return
                            })
                    self.wait(for: [failure, value], timeout: testTimeout)
                    cancellable.cancel()
                }
            }
            context("with decode error") {
                beforeEach {
                    // Stub mock to return a valid network response but an invalid json.
                    URLProtocolMock.response = self.createValidResponse(for: Self.children24URL)
                    URLProtocolMock.testURLs = [Self.children24URL: Data("".utf8)]
                }
                it("only the failure completion callback should be triggered") {
                    let failure = XCTestExpectation(description: "failure received")
                    let value = XCTestExpectation(description: "value received")
                    value.isInverted = true

                    let cancellable
                        = target.getHymn(children24)
                            .sink(receiveCompletion: { state in
                                failure.fulfill()
                                expect(state).to(equal(.failure(.parsing(description: "The data couldn’t be read because it isn’t in the correct format."))))
                            }, receiveValue: { _ in
                                value.fulfill()
                                return
                            })
                    self.wait(for: [failure, value], timeout: testTimeout)
                    cancellable.cancel()
                }
            }
            context("with a valid response") {
                beforeEach {
                    // Stub mock to return a valid network response but an invalid json.
                    URLProtocolMock.response = self.createValidResponse(for: Self.children24URL)
                    URLProtocolMock.testURLs = [Self.children24URL: Data(children_24_json.utf8)]
                }
                it("the finished completion and receive value callbacks should be triggered") {
                    let finished = XCTestExpectation(description: "finished received")
                    let value = XCTestExpectation(description: "value received")

                    let cancellable
                        = target.getHymn(children24)
                            .sink(
                                receiveCompletion: { state in
                                    finished.fulfill()
                                    expect(state).to(equal(.finished))
                            }, receiveValue: { hymn in
                                value.fulfill()
                                expect(hymn).to(equal(children_24_hymn))
                            })
                    self.wait(for: [finished, value], timeout: testTimeout)
                    cancellable.cancel()
                }
            }
            context("with a valid response and the request contains query paramters") {
                beforeEach {
                    // Stub mock to return a valid network response but an invalid json.
                    URLProtocolMock.response = self.createValidResponse(for: Self.children24URL)
                    URLProtocolMock.testURLs = [Self.children24QueryParamsURL: Data(children_24_json.utf8)]
                }
                it("the finished completion and receive value callbacks should be triggered") {
                    let finished = XCTestExpectation(description: "finished received")
                    let value = XCTestExpectation(description: "value received")

                    let identifier = HymnIdentifier(hymnType: .children, hymnNumber: "24", queryParams: ["key1": "value1"])
                    let cancellable
                        = target.getHymn(identifier)
                            .sink(
                                receiveCompletion: { state in
                                    finished.fulfill()
                                    expect(state).to(equal(.finished))
                            }, receiveValue: { hymn in
                                value.fulfill()
                                expect(hymn).to(equal(children_24_hymn))
                            })
                    self.wait(for: [finished, value], timeout: testTimeout)
                    cancellable.cancel()
                }
            }
        }
    }
}

extension HymnalApiService_GetHymnSpec {
    static let children24URL = URL(string: "http://hymnalnetapi.herokuapp.com/v2/hymn/c/24")!
    static let children24QueryParamsURL = URL(string: "http://hymnalnetapi.herokuapp.com/v2/hymn/c/24?key1=value1")!
}
