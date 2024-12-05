import Combine
import Quick
import Mockingbird
import Nimble
import Resolver
@testable import Hymns

class HymnalNetServiceSpec: AsyncSpec {

    override class func spec() {
        describe("get data") {
            let url = URL(string: "https://www.hymnal.net/en/hymn/h/767/f=mp3")!
            var target: HymnalNetServiceImpl!
            beforeEach {
                let config = URLSessionConfiguration.ephemeral
                config.protocolClasses = [URLProtocolMock.self]
                let session = URLSession(configuration: config)
                target = HymnalNetServiceImpl(session: session)
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
                        = target.getData(url)
                            .sink(receiveCompletion: { state in
                                failure.fulfill()
                                expect(state).to(equal(.failure(.data(description: "The operation couldn’t be completed. (NSURLErrorDomain error -1.)"))))
                            }, receiveValue: { _ in
                                value.fulfill()
                                return
                            })
                    await current.fulfillment(of: [failure, value], timeout: testTimeout)
                    cancellable.cancel()
                }
            }
            context("with a valid response") {
                let path = Bundle(for: AudioPlayerViewModelSpec.self).path(forResource: "e0767_i", ofType: "mp3")!
                // swiftlint:disable:next force_try
                let expected = try! Data(contentsOf: URL(fileURLWithPath: path))
                beforeEach {
                    // Stub mock to return a valid network response but an invalid json.
                    URLProtocolMock.response = Self.createValidResponse(for: url)
                    URLProtocolMock.testURLs = [url: expected]
                }
                it("the finished completion and receive value callbacks should be triggered") {
                    let finished = XCTestExpectation(description: "finished received")
                    let value = XCTestExpectation(description: "value received")

                    let cancellable
                        = target.getData(url)
                            .sink(
                                receiveCompletion: { state in
                                    finished.fulfill()
                                    expect(state).to(equal(.finished))
                            }, receiveValue: { actual in
                                value.fulfill()
                                expect(actual).to(equal(expected))
                            })
                    await current.fulfillment(of: [finished, value], timeout: testTimeout)
                    cancellable.cancel()
                }
            }
        }
    }
}
