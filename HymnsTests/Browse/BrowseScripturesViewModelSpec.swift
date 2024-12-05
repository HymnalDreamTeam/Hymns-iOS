import Combine
import Mockingbird
import Nimble
import Quick
@testable import Hymns

class BrowseScripturesViewModelSpec: QuickSpec {

    override class func spec() {
        describe("fetching scripture songs") {
            let testQueue = DispatchQueue(label: "test_queue")
            var repository: BrowseRepositoryMock!
            var target: BrowseScripturesViewModel!
            beforeEach {
                repository = mock(BrowseRepository.self)
                target = BrowseScripturesViewModel(backgroundQueue: testQueue, mainQueue: testQueue, repository: repository)
            }
            context("repository error") {
                beforeEach {
                    given(repository.scriptureSongs()) ~> {
                        Just([ScriptureResult]())
                            .tryMap({ _ -> [ScriptureResult] in
                                throw URLError(.badServerResponse)
                            }).mapError({ _ -> ErrorType in
                                ErrorType.data(description: "forced data error")
                            }).eraseToAnyPublisher()
                    }
                }
                describe("fetching scripture songs") {
                    beforeEach {
                        target.fetchScriptureSongs()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("scriptures should be nil") {
                        expect(target.scriptures).to(beNil())
                    }
                }
            }
            context("repository empty") {
                beforeEach {
                    given(repository.scriptureSongs()) ~> {
                        Just([ScriptureResult]()).mapError({ _ -> ErrorType in
                            // This will never be triggered.
                        }).eraseToAnyPublisher()
                    }
                }
                describe("fetching scripture songs") {
                    beforeEach {
                        target.fetchScriptureSongs()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("scriptures should be nil") {
                        expect(target.scriptures).to(beNil())
                    }
                }
            }
            context("repository results") {
                let scriptureResults = [ScriptureResult(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1152"), title: "hymn1", book: .genesis, chapter: "1", verse: "26-30"),
                                        ScriptureResult(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1151"), title: "Hymn: hymn2", book: .genesis, chapter: "1", verse: "26"),
                                        ScriptureResult(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1153"), title: "hymn3", book: .genesis, chapter: "1", verse: "27"),
                                        ScriptureResult(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1154"), title: "hymn4", book: .john, chapter: "1", verse: "4"),
                                        ScriptureResult(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1157"), title: "hymn7", book: .john, chapter: "2", verse: "1"),
                                        ScriptureResult(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1155"), title: "hymn5", book: .john, chapter: nil, verse: nil),
                                        ScriptureResult(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1156"), title: "hymn6", book: .john, chapter: "1", verse: nil)]
                beforeEach {
                    given(repository.scriptureSongs()) ~> {
                        Just(scriptureResults).mapError({ _ -> ErrorType in
                            // This will never be triggered.
                        }).eraseToAnyPublisher()
                    }
                }
                describe("fetching scripture songs") {
                    beforeEach {
                        target.fetchScriptureSongs()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    let expected =
                        [ScriptureViewModel(book: .genesis,
                                            scriptureSongs: [ScriptureSongViewModel(reference: "1:26", title: "Hymn: hymn2", hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1151")),
                                                             ScriptureSongViewModel(reference: "1:26-30", title: "hymn1", hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1152")),
                                                             ScriptureSongViewModel(reference: "1:27", title: "hymn3", hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1153"))]),
                         ScriptureViewModel(book: .john,
                                            scriptureSongs: [ScriptureSongViewModel(reference: "General", title: "hymn5", hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1155")),
                                                             ScriptureSongViewModel(reference: "1", title: "hymn6", hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1156")),
                                                             ScriptureSongViewModel(reference: "1:4", title: "hymn4", hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1154")),
                                                             ScriptureSongViewModel(reference: "2:1", title: "hymn7", hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "1157"))])]
                    it("shouold have the correct view models") {
                        expect(target.scriptures).to(equal(expected))
                    }
                }
            }
        }
    }
}
