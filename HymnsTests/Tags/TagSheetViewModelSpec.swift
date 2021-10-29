import Combine
import Quick
import Mockingbird
import Nimble
import RealmSwift
@testable import Hymns

class TagSheetViewModelSpec: QuickSpec {
    override func spec() {
        describe("TagSheetViewModelSpec") {
            // https://www.vadimbulavin.com/unit-testing-async-code-in-swift/
            let testQueue = DispatchQueue(label: "test_queue")
            var hymnsRepository: HymnsRepositoryMock!
            var tagStore: TagStoreMock!
            var target: TagSheetViewModel!
            beforeEach {
                hymnsRepository = mock(HymnsRepository.self)
                tagStore = mock(TagStore.self)
                target = TagSheetViewModel(hymnToDisplay: cebuano123,
                                           tagStore: tagStore, hymnsRepository: hymnsRepository,
                                           mainQueue: testQueue, backgroundQueue: testQueue)
            }
            context("initial state") {
                it("should have an empty title") {
                    expect(target.title).to(beEmpty())
                }
                it("should have an empty tags") {
                    expect(target.tags).to(beEmpty())
                }
            }
            describe("fetching a hymn") {
                context("with nil repository result") {
                    beforeEach {
                        given(hymnsRepository.getHymn(cebuano123)) ~> { _ in
                            Just(nil).assertNoFailure().eraseToAnyPublisher()
                        }
                        target.fetchHymn()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should have an empty title") {
                        expect(target.title).to(beEmpty())
                    }
                }
                context("with empty title") {
                    beforeEach {
                        given(hymnsRepository.getHymn(cebuano123)) ~> { _ in
                            Just(UiHymn(hymnIdentifier: cebuano123, title: "", lyrics: [Verse]()))
                                .assertNoFailure().eraseToAnyPublisher()
                        }
                        target.fetchHymn()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should have an empty title") {
                        expect(target.title).to(beEmpty())
                    }
                }
                context("classic song title") {
                    beforeEach {
                        given(hymnsRepository.getHymn(cebuano123)) ~> { _ in
                            Just(UiHymn(hymnIdentifier: classic1151, title: "title here", lyrics: [Verse]()))
                                .assertNoFailure().eraseToAnyPublisher()
                        }
                        target.fetchHymn()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should prepend hymn number to the song's title") {
                        expect(target.title).to(equal("Hymn 1151: title here"))
                    }
                }
                context("non-classic song title") {
                    beforeEach {
                        given(hymnsRepository.getHymn(cebuano123)) ~> { _ in
                            Just(UiHymn(hymnIdentifier: cebuano123, title: "title here", lyrics: [Verse]()))
                                .assertNoFailure().eraseToAnyPublisher()
                        }
                        target.fetchHymn()
                        testQueue.sync {}
                        testQueue.sync {}
                        testQueue.sync {}
                    }
                    it("should use the song's title") {
                        expect(target.title).to(equal("title here"))
                    }
                }
            }
            describe("fetching tags") {
                context("data store error") {
                    beforeEach {
                        given(tagStore.getTagsForHymn(hymnIdentifier: cebuano123)) ~> { _ in
                            Just([Tag]())
                                .tryMap({ _ -> [Tag] in
                                    throw URLError(.badServerResponse)
                                }).mapError({ _ -> ErrorType in
                                    .data(description: "forced data error")
                                }).eraseToAnyPublisher()
                        }
                        target.fetchTags()
                        testQueue.sync {}
                    }
                    it("tags should be empty") {
                        expect(target.tags).to(beEmpty())
                    }
                }
                context("data store empty") {
                    beforeEach {
                        given(tagStore.getTagsForHymn(hymnIdentifier: cebuano123)) ~> { _ in
                            Just([Tag]()).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }
                        target.fetchTags()
                        testQueue.sync {}
                    }
                    it("tags should be empty") {
                        expect(target.tags).to(beEmpty())
                    }
                }
                context("data store results") {
                    let tags = [Tag(hymnIdentifier: cebuano123, songTitle: "title 1 should be ignored", tag: "tag 1", color: .none),
                                Tag(hymnIdentifier: classic40, songTitle: "title 2 should be ignored", tag: "tag 2", color: .blue),
                                Tag(hymnIdentifier: classic500, songTitle: "title 3 should be ignored", tag: "tag 3", color: .green),
                                Tag(hymnIdentifier: chinese216, songTitle: "title 4 should be ignored", tag: "tag 4", color: .none)]
                    beforeEach {
                        given(tagStore.getTagsForHymn(hymnIdentifier: cebuano123)) ~> { _ in
                            Just(tags).mapError({ _ -> ErrorType in
                                // This will never be triggered.
                            }).eraseToAnyPublisher()
                        }
                        target.fetchTags()
                        testQueue.sync {}
                    }
                    it("should have the correct tags") {
                        let expected = [UiTag(title: "tag 1", color: .none),
                                        UiTag(title: "tag 2", color: .blue),
                                        UiTag(title: "tag 3", color: .green),
                                        UiTag(title: "tag 4", color: .none)]
                        expect(target.tags).to(equal(expected))
                    }
                }
            }
            describe("add and delete tags") {
                it("should call the tagStore") {
                    target.title = "cebuano 123"
                    target.addTag(tagTitle: "title 1", tagColor: .green)
                    target.addTag(tagTitle: "title 2", tagColor: .none)
                    target.deleteTag(tagTitle: "title 1", tagColor: .green)
                    target.deleteTag(tagTitle: "title 3", tagColor: .blue)
                    verify(tagStore.storeTag(Tag(hymnIdentifier: cebuano123, songTitle: "cebuano 123", tag: "title 1", color: .green))).wasCalled(exactly(1))
                    verify(tagStore.storeTag(Tag(hymnIdentifier: cebuano123, songTitle: "cebuano 123", tag: "title 2", color: .none))).wasCalled(exactly(1))
                    verify(tagStore.deleteTag(Tag(hymnIdentifier: cebuano123, songTitle: "cebuano 123", tag: "title 1", color: .green))).wasCalled(exactly(1))
                    verify(tagStore.deleteTag(Tag(hymnIdentifier: cebuano123, songTitle: "cebuano 123", tag: "title 1", color: .green))).wasCalled(exactly(1))
                }
            }
        }
    }
}
