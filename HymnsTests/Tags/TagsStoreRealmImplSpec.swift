import Combine
import Quick
import Mockingbird
import Nimble
import RealmSwift
@testable import Hymns

// swiftlint:disable type_body_length function_body_length cyclomatic_complexity
class TagStoreRealmImplSpec: QuickSpec {

    override func spec() {
        describe("using an in-memory realm") {
            var inMemoryRealm: Realm!
            var target: TagStoreRealmImpl!
            beforeEach {
                // Don't worry about force_try in tests.
                // swiftlint:disable:next force_try
                inMemoryRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "TagStoreMock"))
                target = TagStoreRealmImpl(realm: inMemoryRealm)
            }
            afterEach {
                // Don't worry about force_try in tests.
                // swiftlint:disable:next force_try
                try! inMemoryRealm.write {
                    inMemoryRealm.deleteAll()
                }
                inMemoryRealm.invalidate()
            }
            describe("store a few tags") {
                beforeEach {
                    target.storeTag(Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Christ", color: .blue))
                    target.storeTag(Tag(hymnIdentifier: newSong145, songTitle: "Hymn: Jesus shall reign where\\u2019er the sun", tag: "Bread and wine", color: .yellow))
                    target.storeTag(Tag(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014", tag: "Table", color: .blue))
                    target.storeTag(Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Is", color: .red))
                    target.storeTag(Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Life", color: .red))
                    target.storeTag(Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Peace", color: .blue))
                    target.storeTag(Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Peace", color: .yellow))
                }
                describe("getting one hymn's tags after storing multiple tags for that hymn") {
                    beforeEach {
                        target.storeTag(Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Is", color: .red))
                        target.storeTag(Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Life", color: .red))
                        target.storeTag(Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Peace", color: .blue))
                    }
                    it("should return the tags for that hymn") {
                        let failure = self.expectation(description: "Invalid.failure")
                        failure.isInverted = true
                        let finished = self.expectation(description: "Invalid.finished")
                        // finished should not be called because this is a self-updating publisher.
                        finished.isInverted = true
                        let value = self.expectation(description: "Invalid.receiveValue")

                        let cancellable = target.getTagsForHymn(hymnIdentifier: classic1151)
                            .sink(receiveCompletion: { (completion: Subscribers.Completion<ErrorType>) -> Void in
                                switch completion {
                                case .failure:
                                    failure.fulfill()
                                case .finished:
                                    finished.fulfill()
                                }
                                return
                            }, receiveValue: { tags in
                                value.fulfill()
                                expect(tags).to(equal([Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Peace", color: .blue),
                                                       Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Life", color: .red),
                                                       Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Is", color: .red),
                                                       Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Peace", color: .yellow),
                                                       Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Christ", color: .blue)]))
                            })
                        await self.fulfillment(of: [failure, finished, value], timeout: testTimeout)
                        cancellable.cancel()
                    }
                }
                describe("deleting a tag") {
                    var failure: XCTestExpectation!
                    var finished: XCTestExpectation!
                    var value: XCTestExpectation!
                    beforeEach {
                        failure = self.expectation(description: "Invalid.failure")
                        failure.isInverted = true
                        finished = self.expectation(description: "Invalid.finished")
                        // finished should not be called because this is a self-updating publisher.
                        finished.isInverted = true
                        value = self.expectation(description: "Invalid.receiveValue")
                    }
                    it("should delete the tag") {
                        value.expectedFulfillmentCount = 2
                        var count = 0
                        let cancellable = target.getSongsByTag(UiTag(title: "Table", color: .blue))
                            .sink(receiveCompletion: { state in
                                switch state {
                                case .failure:
                                    failure.fulfill()
                                case .finished:
                                    finished.fulfill()
                                }
                                return
                            }, receiveValue: { songResults in
                                value.fulfill()
                                count += 1
                                if count == 1 {
                                    expect(songResults).to(haveCount(1))
                                } else if count == 2 {
                                    expect(songResults).to(haveCount(0))
                                } else {
                                    fail("count should only be either 1 or 2")
                                }
                            })
                        target.deleteTag(Tag(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014", tag: "Table", color: .blue))
                        await self.fulfillment(of: [failure, finished, value], timeout: testTimeout)
                        cancellable.cancel()
                    }
                    it("should be case sensitive") {
                        let cancellable = target.getSongsByTag(UiTag(title: "Table", color: .blue))
                            .sink(receiveCompletion: { state in
                                switch state {
                                case .failure:
                                    failure.fulfill()
                                case .finished:
                                    finished.fulfill()
                                }
                                return
                            }, receiveValue: { songResults in
                                value.fulfill()
                                expect(songResults).to(haveCount(1))
                            })
                        target.deleteTag(Tag(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014", tag: "table", color: .blue))
                        await self.fulfillment(of: [failure, finished, value], timeout: testTimeout)
                        cancellable.cancel()
                    }
                    it("not delete if the color doesn't match") {
                        let cancellable = target.getSongsByTag(UiTag(title: "Table", color: .blue))
                            .sink(receiveCompletion: { state in
                                switch state {
                                case .failure:
                                    failure.fulfill()
                                case .finished:
                                    finished.fulfill()
                                }
                                return
                            }, receiveValue: { songResults in
                                value.fulfill()
                                expect(songResults).to(haveCount(1))
                            })
                        target.deleteTag(Tag(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014", tag: "Table", color: .green))
                        await self.fulfillment(of: [failure, finished, value], timeout: testTimeout)
                        cancellable.cancel()
                    }
                }
                describe("getting songs for a tag") {
                    beforeEach {
                        target.storeTag(Tag(hymnIdentifier: classic500, songTitle: "Hymn 500", tag: "Christ", color: .blue))
                        target.storeTag(Tag(hymnIdentifier: classic1109, songTitle: "Hymn 1109", tag: "Christ", color: .blue))
                        target.storeTag(Tag(hymnIdentifier: cebuano123, songTitle: "Cebuano 123", tag: "Christ", color: .red))
                    }
                    it("should return the correct songs") {
                        let failure = self.expectation(description: "Invalid.failure")
                        failure.isInverted = true
                        let finished = self.expectation(description: "Invalid.finished")
                        // finished should not be called because this is a self-updating publisher.
                        finished.isInverted = true
                        let value = self.expectation(description: "Invalid.receiveValue")

                        let cancellable = target.getSongsByTag(UiTag(title: "Christ", color: .blue))
                            .sink(receiveCompletion: { (completion: Subscribers.Completion<ErrorType>) -> Void in
                                switch completion {
                                case .failure:
                                    failure.fulfill()
                                case .finished:
                                    finished.fulfill()
                                }
                                return
                            }, receiveValue: { songResults in
                                value.fulfill()
                                expect(songResults).to(contain([SongResultEntity(hymnType: .classic, hymnNumber: "1109", title: "Hymn 1109"),
                                                                SongResultEntity(hymnType: .classic, hymnNumber: "500", title: "Hymn 500"),
                                                                SongResultEntity(hymnType: .classic, hymnNumber: "1151", title: "Hymn 1151")]))
                            })
                        await self.fulfillment(of: [failure, finished, value], timeout: testTimeout)
                        cancellable.cancel()
                    }
                }
                describe("getting unique tags") {
                    it("should return all the unique tags") {
                        let failure = self.expectation(description: "Invalid.failure")
                        failure.isInverted = true
                        let finished = self.expectation(description: "Invalid.finished")
                        // finished should not be called because this is a self-updating publisher.
                        finished.isInverted = true
                        let value = self.expectation(description: "Invalid.receiveValue")

                        let cancellable = target.getUniqueTags()
                            .sink(receiveCompletion: { state in
                                switch state {
                                case .failure:
                                    failure.fulfill()
                                case .finished:
                                    finished.fulfill()
                                }
                                return
                            }, receiveValue: { tags in
                                value.fulfill()
                                expect(tags).to(contain([UiTag(title: "Peace", color: .yellow),
                                                         UiTag(title: "Peace", color: .blue),
                                                         UiTag(title: "Life", color: .red),
                                                         UiTag(title: "Table", color: .blue),
                                                         UiTag(title: "Christ", color: .blue),
                                                         UiTag(title: "Bread and wine", color: .yellow),
                                                         UiTag(title: "Is", color: .red)]))
                            })
                        await self.fulfillment(of: [failure, finished, value], timeout: testTimeout)
                        cancellable.cancel()
                    }
                }
                context("unique tags changes") {
                    let failure = self.expectation(description: "Invalid.failure")
                    failure.isInverted = true
                    let finished = self.expectation(description: "Invalid.finished")
                    // finished should not be called because this is a self-updating publisher.
                    finished.isInverted = true
                    let value = self.expectation(description: "Invalid.receiveValue")
                    value.expectedFulfillmentCount = 2
                    var cancellable: AnyCancellable?
                    var count = 0
                    beforeEach {
                        cancellable = target.getUniqueTags()
                            .sink(receiveCompletion: { state in
                                switch state {
                                case .failure:
                                    failure.fulfill()
                                case .finished:
                                    finished.fulfill()
                                }
                                return
                            }, receiveValue: { tags in
                                value.fulfill()
                                count += 1
                                if count == 1 {
                                    expect(tags).to(contain([UiTag(title: "Peace", color: .yellow),
                                                             UiTag(title: "Peace", color: .blue),
                                                             UiTag(title: "Life", color: .red),
                                                             UiTag(title: "Table", color: .blue),
                                                             UiTag(title: "Christ", color: .blue),
                                                             UiTag(title: "Bread and wine", color: .yellow),
                                                             UiTag(title: "Is", color: .red)]))
                                } else if count == 2 {
                                    expect(tags).to(contain([UiTag(title: "Peace", color: .yellow),
                                                             UiTag(title: "Peace", color: .blue),
                                                             UiTag(title: "Life", color: .red),
                                                             UiTag(title: "Table", color: .blue),
                                                             UiTag(title: "Christ", color: .blue),
                                                             UiTag(title: "Bread and wine", color: .yellow)]))
                                } else {
                                    fail("count should only be either 1 or 2")
                                }
                            })
                    }
                    it("the correct callbacks should be called") {
                        target.deleteTag(Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Is", color: .red))
                        await self.fulfillment(of: [failure, finished, value], timeout: testTimeout)
                        expect(cancellable).toNot(beNil())
                        cancellable!.cancel()
                    }
                }
            }
        }
    }
}
