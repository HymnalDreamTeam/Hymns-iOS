import Combine
import Mockingbird
import Nimble
import XCTest
@testable import Hymns

class BrowseRepositoryTest: XCTestCase {

    var backgroundQueue = DispatchQueue.init(label: "background test queue")
    var dataStore: HymnDataStoreMock!
    var target: BrowseRepository!

    override func setUp() {
        super.setUp()
        dataStore = mock(HymnDataStore.self)
        target = BrowseRepositoryImpl(dataStore: dataStore)
    }

    func test_getScriptureSongs() {
        given(dataStore.getScriptureSongs()) ~> {
            Just([ScriptureEntity(title: "title", hymnType: .classic, hymnNumber: "43", scriptures: "Revelation 22;Hosea 14:8;;Genesis 1:1-6;7:9;12")])
                .mapError({ _ -> ErrorType in
                    // This will never be triggered.
                }).eraseToAnyPublisher()
        }

        let expected = [ScriptureResult(hymnIdentifier: Hymns.HymnIdentifier(hymnType: .classic, hymnNumber: "43"), title: "title", book: Hymns.Book.revelation, chapter: "22", verse: nil),
                        ScriptureResult(hymnIdentifier: Hymns.HymnIdentifier(hymnType: .classic, hymnNumber: "43"), title: "title", book: Hymns.Book.hosea, chapter: "14", verse: "8"),
                        ScriptureResult(hymnIdentifier: Hymns.HymnIdentifier(hymnType: .classic, hymnNumber: "43"), title: "title", book: Hymns.Book.genesis, chapter: "1", verse: "1-6"),
                        ScriptureResult(hymnIdentifier: Hymns.HymnIdentifier(hymnType: .classic, hymnNumber: "43"), title: "title", book: Hymns.Book.genesis, chapter: "7", verse: "9"),
                        ScriptureResult(hymnIdentifier: Hymns.HymnIdentifier(hymnType: .classic, hymnNumber: "43"), title: "title", book: Hymns.Book.genesis, chapter: "7", verse: "12")]

        let completion = expectation(description: "completion received")
        let value = expectation(description: "value received")
        let cancellable = target.scriptureSongs()
            .print(self.description)
            .sink(receiveCompletion: { state in
                completion.fulfill()
                expect(state).to(equal(.finished))
            }, receiveValue: { scriptureResults in
                value.fulfill()
                expect(scriptureResults).to(equal(expected))
            })

        wait(for: [completion, value], timeout: testTimeout)
        cancellable.cancel()
    }
}
