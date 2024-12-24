import Combine
import Quick
import Mockingbird
import Nimble
import RealmSwift
@testable import Hymns

class FavoriteStoreRealmImplSpec: AsyncSpec {
    override class func spec() {
        describe("using an in-memory realm") {
            var failureExpectation: XCTestExpectation!
            var finishedExpectation: XCTestExpectation!
            var valueExpectation: XCTestExpectation!
            var cancellable: Cancellable!

            var inMemoryRealm: Realm!
            var target: FavoriteStoreRealmImpl!
            beforeEach {
                failureExpectation = current.expectation(description: "failure")
                failureExpectation.isInverted = true
                finishedExpectation = current.expectation(description: "finished")
                valueExpectation = current.expectation(description: "value")

                DispatchQueue.main.sync {
                    // Don't worry about force_try in tests.
                    // swiftlint:disable:next force_try
                    inMemoryRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "FavoriteStoreRealmImplSpec"))
                    target = FavoriteStoreRealmImpl(realm: inMemoryRealm)
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
            context("store a few favorites") {
                beforeEach {
                    DispatchQueue.main.sync {
                        target.storeFavorite(FavoriteEntity(hymnIdentifier: classic1151, songTitle: "Hymn 1151"))
                        target.storeFavorite(FavoriteEntity(hymnIdentifier: newSong145, songTitle: "Hymn: Jesus shall reign where\\u2019er the sun"))
                        target.storeFavorite(FavoriteEntity(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014"))
                    }
                }
                describe("get the list of all favorites") {
                    it("should get all favorited songs") {
                        // finished should not be called because this is a self-updating publisher.
                        finishedExpectation.isInverted = true

                        DispatchQueue.main.sync {
                            cancellable = target.favorites()
                                .sink(receiveCompletion: { (completion: Subscribers.Completion<ErrorType>) in
                                    switch completion {
                                    case .failure:
                                        failureExpectation.fulfill()
                                    case .finished:
                                        finishedExpectation.fulfill()
                                    }
                                    return
                                }, receiveValue: { entities in
                                    valueExpectation.fulfill()
                                    expect(entities).to(equal([FavoriteEntity(hymnIdentifier: classic1151, songTitle: "Hymn 1151"),
                                                               FavoriteEntity(hymnIdentifier: newSong145, songTitle: "Hymn: Jesus shall reign where\\u2019er the sun"),
                                                               FavoriteEntity(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014")]))
                                })
                        }
                    }
                    it("cebuano123 should be favorited") {
                        // finished should not be called because this is a self-updating publisher.
                        finishedExpectation.isInverted = true

                        DispatchQueue.main.sync {
                            cancellable = target.isFavorite(hymnIdentifier: cebuano123)
                                .sink(receiveCompletion: { (completion: Subscribers.Completion<ErrorType>) in
                                    switch completion {
                                    case .failure:
                                        failureExpectation.fulfill()
                                    case .finished:
                                        finishedExpectation.fulfill()
                                    }
                                    return
                                }, receiveValue: { isFavorite in
                                    valueExpectation.fulfill()
                                    expect(isFavorite).to(beTrue())
                                })
                        }
                    }
                    context("favorites status changes") {
                        var count = 0
                        beforeEach {
                            // finished should not be called because this is a self-updating publisher.
                            finishedExpectation.isInverted = true
                            valueExpectation.expectedFulfillmentCount = 2

                            DispatchQueue.main.sync {
                                cancellable = target.isFavorite(hymnIdentifier: cebuano123)
                                    .sink(receiveCompletion: { (completion: Subscribers.Completion<ErrorType>) in
                                        switch completion {
                                        case .failure:
                                            failureExpectation.fulfill()
                                        case .finished:
                                            finishedExpectation.fulfill()
                                        }
                                        return
                                    }, receiveValue: { isFavorite in
                                        valueExpectation.fulfill()
                                        count += 1
                                        if count == 1 {
                                            expect(isFavorite).to(beTrue())
                                        } else if count == 2 {
                                            expect(isFavorite).to(beFalse())
                                        } else {
                                            fail("count should only be either 1 or 2")
                                        }
                                    })
                            }
                        }
                        it("the correct callbacks should be called") {
                            // Calling delete should trigger the sink operation above again.
                            DispatchQueue.main.sync {
                                target.deleteFavorite(primaryKey: FavoriteEntity.createPrimaryKey(hymnIdentifier: cebuano123))
                            }
                        }
                    }
                }
            }
        }
    }
}
