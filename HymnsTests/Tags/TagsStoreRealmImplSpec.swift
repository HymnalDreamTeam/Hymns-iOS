import Combine
import Quick
import Mockingbird
import Nimble
import RealmSwift
@testable import Hymns

// swiftlint:disable type_body_length function_body_length cyclomatic_complexity
class TagStoreRealmImplSpec: AsyncSpec {

    override class func spec() {
        describe("using an in-memory realm") {
            var failureExpectation: XCTestExpectation!
            var finishedExpectation: XCTestExpectation!
            var valueExpectation: XCTestExpectation!
            var cancellable: Cancellable!

            var inMemoryRealm: Realm!
            var target: TagStoreRealmImpl!
            beforeEach {
                failureExpectation = current.expectation(description: "failure")
                failureExpectation.isInverted = true
                finishedExpectation = current.expectation(description: "finished")
                valueExpectation = current.expectation(description: "value")

                DispatchQueue.main.sync {
                    // Don't worry about force_try in tests.
                    // swiftlint:disable:next force_try
                    inMemoryRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "TagStoreMock"))
                    target = TagStoreRealmImpl(realm: inMemoryRealm)
                }
            }
            afterEach {
                await current.fulfillment(of: [failureExpectation, finishedExpectation, valueExpectation], timeout: testTimeout)
                cancellable.cancel()

                DispatchQueue.main.sync {
                    // Don't worry about force_try in tests.
                    // swiftlint:disable:next force_try
                    try! inMemoryRealm.write {
                        inMemoryRealm.deleteAll()
                    }
                    inMemoryRealm.invalidate()
                }
            }
            describe("store a few tags") {
                beforeEach {
                    DispatchQueue.main.sync {
                        target.storeTag(Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Christ", color: .blue))
                        target.storeTag(Tag(hymnIdentifier: newSong145, songTitle: "Hymn: Jesus shall reign where\\u2019er the sun", tag: "Bread and wine", color: .yellow))
                        target.storeTag(Tag(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014", tag: "Table", color: .blue))
                        target.storeTag(Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Is", color: .red))
                        target.storeTag(Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Life", color: .red))
                        target.storeTag(Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Peace", color: .blue))
                        target.storeTag(Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Peace", color: .yellow))
                    }
                }
                describe("getting one hymn's tags after storing multiple tags for that hymn") {
                    beforeEach {
                        DispatchQueue.main.sync {
                            target.storeTag(Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Is", color: .red))
                            target.storeTag(Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Life", color: .red))
                            target.storeTag(Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Peace", color: .blue))
                        }
                    }
                    it("should return the tags for that hymn") {
                        // finished should not be called because this is a self-updating publisher.
                        finishedExpectation.isInverted = true

                        DispatchQueue.main.sync {
                            cancellable = target.getTagsForHymn(hymnIdentifier: classic1151)
                                .sink(receiveCompletion: { (completion: Subscribers.Completion<ErrorType>) in
                                    switch completion {
                                    case .failure:
                                        failureExpectation.fulfill()
                                    case .finished:
                                        finishedExpectation.fulfill()
                                    }
                                    return
                                }, receiveValue: { tags in
                                    valueExpectation.fulfill()
                                    expect(tags).to(equal([Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Peace", color: .blue),
                                                           Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Life", color: .red),
                                                           Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Is", color: .red),
                                                           Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Peace", color: .yellow),
                                                           Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Christ", color: .blue)]))
                                })
                        }
                    }
                }
                describe("deleting a tag") {
                    beforeEach {
                        // finished should not be called because this is a self-updating publisher.
                        finishedExpectation.isInverted = true
                    }
                    it("should delete the tag") {
                        valueExpectation.expectedFulfillmentCount = 2
                        var count = 0
                        DispatchQueue.main.sync {
                            cancellable = target.getSongsByTag(UiTag(title: "Table", color: .blue))
                                .sink(receiveCompletion: { state in
                                    switch state {
                                    case .failure:
                                        failureExpectation.fulfill()
                                    case .finished:
                                        finishedExpectation.fulfill()
                                    }
                                    return
                                }, receiveValue: { songResults in
                                    valueExpectation.fulfill()
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
                        }
                    }
                    it("should be case sensitive") {
                        DispatchQueue.main.sync {
                            cancellable = target.getSongsByTag(UiTag(title: "Table", color: .blue))
                                .sink(receiveCompletion: { state in
                                    switch state {
                                    case .failure:
                                        failureExpectation.fulfill()
                                    case .finished:
                                        finishedExpectation.fulfill()
                                    }
                                    return
                                }, receiveValue: { songResults in
                                    valueExpectation.fulfill()
                                    expect(songResults).to(haveCount(1))
                                })
                            target.deleteTag(Tag(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014", tag: "table", color: .blue))
                        }
                    }
                    it("not delete if the color doesn't match") {
                        DispatchQueue.main.sync {
                            cancellable = target.getSongsByTag(UiTag(title: "Table", color: .blue))
                                .sink(receiveCompletion: { state in
                                    switch state {
                                    case .failure:
                                        failureExpectation.fulfill()
                                    case .finished:
                                        finishedExpectation.fulfill()
                                    }
                                    return
                                }, receiveValue: { songResults in
                                    valueExpectation.fulfill()
                                    expect(songResults).to(haveCount(1))
                                })
                            target.deleteTag(Tag(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014", tag: "Table", color: .green))
                        }
                    }
                }
                describe("getting songs for a tag") {
                    beforeEach {
                        DispatchQueue.main.sync {
                            target.storeTag(Tag(hymnIdentifier: classic500, songTitle: "Hymn 500", tag: "Christ", color: .blue))
                            target.storeTag(Tag(hymnIdentifier: classic1109, songTitle: "Hymn 1109", tag: "Christ", color: .blue))
                            target.storeTag(Tag(hymnIdentifier: cebuano123, songTitle: "Cebuano 123", tag: "Christ", color: .red))
                        }
                    }
                    it("should return the correct songs") {
                        // finished should not be called because this is a self-updating publisher.
                        finishedExpectation.isInverted = true

                        DispatchQueue.main.sync {
                            cancellable = target.getSongsByTag(UiTag(title: "Christ", color: .blue))
                                .sink(receiveCompletion: { (completion: Subscribers.Completion<ErrorType>) in
                                    switch completion {
                                    case .failure:
                                        failureExpectation.fulfill()
                                    case .finished:
                                        finishedExpectation.fulfill()
                                    }
                                    return
                                }, receiveValue: { songResults in
                                    valueExpectation.fulfill()
                                    expect(songResults).to(contain([SongResultEntity(hymnType: .classic, hymnNumber: "1109", title: "Hymn 1109"),
                                                                    SongResultEntity(hymnType: .classic, hymnNumber: "500", title: "Hymn 500"),
                                                                    SongResultEntity(hymnType: .classic, hymnNumber: "1151", title: "Hymn 1151")]))
                                })
                        }
                    }
                }
                describe("getting unique tags") {
                    it("should return all the unique tags") {
                        // finished should not be called because this is a self-updating publisher.
                        finishedExpectation.isInverted = true

                        DispatchQueue.main.sync {
                            cancellable = target.getUniqueTags()
                                .sink(receiveCompletion: { state in
                                    switch state {
                                    case .failure:
                                        failureExpectation.fulfill()
                                    case .finished:
                                        finishedExpectation.fulfill()
                                    }
                                    return
                                }, receiveValue: { tags in
                                    valueExpectation.fulfill()
                                    expect(tags).to(contain([UiTag(title: "Peace", color: .yellow),
                                                             UiTag(title: "Peace", color: .blue),
                                                             UiTag(title: "Life", color: .red),
                                                             UiTag(title: "Table", color: .blue),
                                                             UiTag(title: "Christ", color: .blue),
                                                             UiTag(title: "Bread and wine", color: .yellow),
                                                             UiTag(title: "Is", color: .red)]))
                                })
                        }
                    }
                }
                context("unique tags changes") {
                    var count = 0
                    beforeEach {
                        // finished should not be called because this is a self-updating publisher.
                        finishedExpectation.isInverted = true
                        valueExpectation.expectedFulfillmentCount = 2

                        DispatchQueue.main.sync {
                            cancellable = target.getUniqueTags()
                                .sink(receiveCompletion: { state in
                                    switch state {
                                    case .failure:
                                        failureExpectation.fulfill()
                                    case .finished:
                                        finishedExpectation.fulfill()
                                    }
                                    return
                                }, receiveValue: { tags in
                                    valueExpectation.fulfill()
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
                    }
                    it("the correct callbacks should be called") {
                        // Calling delete should trigger the sink operation above again.
                        DispatchQueue.main.sync {
                            target.deleteTag(Tag(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Is", color: .red))
                        }
                    }
                }
            }
        }
    }
}
