import Combine
import Quick
import Mockingbird
import Nimble
import RealmSwift
@testable import Hymns

class TagListViewModelSpec: QuickSpec {
    override func spec() {
        // https://www.vadimbulavin.com/unit-testing-async-code-in-swift/
        let testQueue = DispatchQueue(label: "test_queue")
        var tagStore: TagStoreMock!
        var target: TagListViewModel!
        describe("fetching unique tags") {
            beforeEach {
                tagStore = mock(TagStore.self)
                target = TagListViewModel(mainQueue: testQueue, tagStore: tagStore)
            }
            context("initial state") {
                it("tags should be nil") {
                    expect(target.tags).to(beNil())
                }
            }

            context("data store error") {
                beforeEach {
                    given(tagStore.getUniqueTags()) ~> {
                        Just([String]())
                            .tryMap({ _ -> [String] in
                                throw URLError(.badServerResponse)
                            }).mapError({ _ -> ErrorType in
                                .data(description: "forced data error")
                            }).eraseToAnyPublisher()
                    }
                    target.fetchUniqueTags()
                    testQueue.sync {}
                }
                it("tags should be empty") {
                    expect(target.tags).to(beEmpty())
                }
            }
            context("data store empty") {
                beforeEach {
                    given(tagStore.getUniqueTags()) ~> {
                        Just([String]()).mapError({ _ -> ErrorType in
                            .data(description: "This will never get called")
                        }).eraseToAnyPublisher()
                    }
                    target.fetchUniqueTags()
                    testQueue.sync {}
                }
                it("tags should be empty") {
                    expect(target.tags).to(beEmpty())
                }
            }
            context("data store results") {
                let uniqueTags = ["tag 1", "tag 2", "tag 3", "tag 4"]
                beforeEach {
                    given(tagStore.getUniqueTags()) ~> {
                        Just(uniqueTags).mapError({ _ -> ErrorType in
                            .data(description: "This will never get called")
                        }).eraseToAnyPublisher()
                    }
                    target.fetchUniqueTags()
                    testQueue.sync {}
                }
                it("should have the correct tags") {
                    expect(target.tags).to(equal(uniqueTags))
                }
            }
        }
    }
}
