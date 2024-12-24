import Combine
import Quick
import Mockingbird
import Nimble
import RealmSwift
@testable import Hymns

class HistoryStoreRealmImplSpec: AsyncSpec {

    override class func spec() {
        describe("using an in-memory realm") {
            var failureExpectation: XCTestExpectation!
            var finishedExpectation: XCTestExpectation!
            var valueExpectation: XCTestExpectation!
            var cancellable: Cancellable!

            var inMemoryRealm: Realm!
            var target: HistoryStoreRealmImpl!
            beforeEach {
                failureExpectation = current.expectation(description: "failure")
                failureExpectation.isInverted = true
                finishedExpectation = current.expectation(description: "finished")
                valueExpectation = current.expectation(description: "value")

                DispatchQueue.main.sync {
                    // Don't worry about force_try in tests.
                    // swiftlint:disable:next force_try
                    inMemoryRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "HistoryStoreRealmImplSpec"))
                    target = HistoryStoreRealmImpl(realm: inMemoryRealm)
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

            context("store a few recent songs") {
                beforeEach {
                    DispatchQueue.main.sync {
                        target.storeRecentSong(hymnToStore: classic1151, songTitle: "Hymn 1151")
                        target.storeRecentSong(hymnToStore: newSong145, songTitle: "Hymn: Jesus shall reign where\\u2019er the sun")
                        target.storeRecentSong(hymnToStore: cebuano123, songTitle: "Naghigda sa lubong\\u2014")
                    }
                }
                describe("getting all recent songs") {
                    it("should contain the stored songs sorted by last-stored") {
                        // finished should not be called because this is a self-updating publisher.
                        finishedExpectation.isInverted = true

                        DispatchQueue.main.sync {
                            cancellable = target.recentSongs()
                                .sink(receiveCompletion: { (completion: Subscribers.Completion<ErrorType>) in
                                    switch completion {
                                    case .failure:
                                        failureExpectation.fulfill()
                                    case .finished:
                                        finishedExpectation.fulfill()
                                    }
                                    return
                                }, receiveValue: { recentSongs in
                                    valueExpectation.fulfill()
                                    expect(recentSongs).to(haveCount(3))
                                    expect(recentSongs[0]).to(equal(RecentSong(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014")))
                                    expect(recentSongs[1]).to(equal(RecentSong(hymnIdentifier: newSong145, songTitle: "Hymn: Jesus shall reign where\\u2019er the sun")))
                                    expect(recentSongs[2]).to(equal(RecentSong(hymnIdentifier: classic1151, songTitle: "Hymn 1151")))
                                })
                        }
                    }
                }
                describe("clear recent songs") {
                    beforeEach {
                        DispatchQueue.main.sync {
                            do {
                                try target.clearHistory()
                            } catch let error {
                                fail("clear history threw an error: \(error)")
                            }
                        }
                    }
                    it("getting all recent songs should contain nothing") {
                        // finished should not be called because this is a self-updating publisher.
                        finishedExpectation.isInverted = true

                        DispatchQueue.main.sync {
                            cancellable = target.recentSongs()
                                .sink(receiveCompletion: { (completion: Subscribers.Completion<ErrorType>) in
                                    switch completion {
                                    case .failure:
                                        failureExpectation.fulfill()
                                    case .finished:
                                        finishedExpectation.fulfill()
                                    }
                                    return
                                }, receiveValue: { recentSongs in
                                    valueExpectation.fulfill()
                                    expect(recentSongs).to(beEmpty())
                                })
                        }
                    }
                }
                let numberToStore = 100
                context("store \(numberToStore) recent songs") {
                    beforeEach {
                        DispatchQueue.main.sync {
                            for num in 1...numberToStore {
                                target.storeRecentSong(hymnToStore: HymnIdentifier(hymnType: .classic, hymnNumber: "\(num)"), songTitle: "song \(num)")
                            }
                        }
                    }
                    describe("getting all recent songs") {
                        it("should only contain the 50 last accessed songs") {
                            // finished should not be called because this is a self-updating publisher.
                            finishedExpectation.isInverted = true

                            DispatchQueue.main.sync {
                                cancellable = target.recentSongs()
                                    .sink(receiveCompletion: { (completion: Subscribers.Completion<ErrorType>) in
                                        switch completion {
                                        case .failure:
                                            failureExpectation.fulfill()
                                        case .finished:
                                            finishedExpectation.fulfill()
                                        }
                                        return
                                    }, receiveValue: { recentSongs in
                                        valueExpectation.fulfill()
                                        expect(recentSongs).to(haveCount(50))
                                        for (index, recentSong) in recentSongs.enumerated() {
                                            expect(recentSong).to(equal(RecentSong(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "\(numberToStore - index)"), songTitle: "song \(numberToStore - index)")))
                                        }
                                    })
                            }
                        }
                    }
                }
            }
        }
    }
}
