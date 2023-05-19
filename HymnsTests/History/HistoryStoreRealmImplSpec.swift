import Combine
import Quick
import Mockingbird
import Nimble
import RealmSwift
@testable import Hymns

class HistoryStoreRealmImplSpec: QuickSpec {

    @MainActor
    override func spec() {
        describe("using an in-memory realm") {
            var inMemoryRealm: Realm!
            var target: HistoryStoreRealmImpl!
            beforeEach {
                // Don't worry about force_try in tests.
                // swiftlint:disable:next force_try
                inMemoryRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "HistoryStoreRealmImplSpec"))
                target = HistoryStoreRealmImpl(realm: inMemoryRealm)
            }
            afterEach {
                // Don't worry about force_try in tests.
                // swiftlint:disable:next force_try
                try! inMemoryRealm.write {
                    inMemoryRealm.deleteAll()
                }
                inMemoryRealm.invalidate()
            }

            context("store a few recent songs") {
                beforeEach {
                    target.storeRecentSong(hymnToStore: classic1151, songTitle: "Hymn 1151")
                    target.storeRecentSong(hymnToStore: newSong145, songTitle: "Hymn: Jesus shall reign where\\u2019er the sun")
                    target.storeRecentSong(hymnToStore: cebuano123, songTitle: "Naghigda sa lubong\\u2014")
                }
                describe("getting all recent songs") {
                    it("should contain the stored songs sorted by last-stored") {
                        let failure = self.expectation(description: "Invalid.failure")
                        failure.isInverted = true
                        let finished = self.expectation(description: "Invalid.finished")
                        // finished should not be called because this is a self-updating publisher.
                        finished.isInverted = true
                        let value = self.expectation(description: "Invalid.receiveValue")

                        let cancellable = target.recentSongs()
                            .sink(receiveCompletion: { (completion: Subscribers.Completion<ErrorType>) -> Void in
                                switch completion {
                                case .failure:
                                    failure.fulfill()
                                case .finished:
                                    finished.fulfill()
                                }
                                return
                            }, receiveValue: { recentSongs in
                                value.fulfill()
                                expect(recentSongs).to(haveCount(3))
                                expect(recentSongs[0]).to(equal(RecentSong(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014")))
                                expect(recentSongs[1]).to(equal(RecentSong(hymnIdentifier: newSong145, songTitle: "Hymn: Jesus shall reign where\\u2019er the sun")))
                                expect(recentSongs[2]).to(equal(RecentSong(hymnIdentifier: classic1151, songTitle: "Hymn 1151")))
                            })
                        await self.fulfillment(of: [failure, finished, value], timeout: testTimeout)
                        cancellable.cancel()
                    }
                }
                describe("clear recent songs") {
                    beforeEach {
                        do {
                            try target.clearHistory()
                        } catch let error {
                            fail("clear history threw an error: \(error)")
                        }
                    }
                    it("getting all recent songs should contain nothing") {
                        let failure = self.expectation(description: "Invalid.failure")
                        failure.isInverted = true
                        let finished = self.expectation(description: "Invalid.finished")
                        // finished should not be called because this is a self-updating publisher.
                        finished.isInverted = true
                        let value = self.expectation(description: "Invalid.receiveValue")

                        let cancellable = target.recentSongs()
                            .sink(receiveCompletion: { (completion: Subscribers.Completion<ErrorType>) -> Void in
                                switch completion {
                                case .failure:
                                    failure.fulfill()
                                case .finished:
                                    finished.fulfill()
                                }
                                return
                            }, receiveValue: { recentSongs in
                                value.fulfill()
                                expect(recentSongs).to(beEmpty())
                            })
                        await self.fulfillment(of: [failure, finished, value], timeout: testTimeout)
                        cancellable.cancel()
                    }
                }
                let numberToStore = 100
                context("store \(numberToStore) recent songs") {
                    beforeEach {
                        for num in 1...numberToStore {
                            target.storeRecentSong(hymnToStore: HymnIdentifier(hymnType: .classic, hymnNumber: "\(num)"), songTitle: "song \(num)")
                        }
                    }
                    describe("getting all recent songs") {
                        it("should only contain the 50 last accessed songs") {
                            let failure = self.expectation(description: "Invalid.failure")
                            failure.isInverted = true
                            let finished = self.expectation(description: "Invalid.finished")
                            // finished should not be called because this is a self-updating publisher.
                            finished.isInverted = true
                            let value = self.expectation(description: "Invalid.receiveValue")

                            let cancellable = target.recentSongs()
                                .sink(receiveCompletion: { (completion: Subscribers.Completion<ErrorType>) -> Void in
                                    switch completion {
                                    case .failure:
                                        failure.fulfill()
                                    case .finished:
                                        finished.fulfill()
                                    }
                                    return
                                }, receiveValue: { recentSongs in
                                    value.fulfill()
                                    expect(recentSongs).to(haveCount(50))
                                    for (index, recentSong) in recentSongs.enumerated() {
                                        expect(recentSong).to(equal(RecentSong(hymnIdentifier: HymnIdentifier(hymnType: .classic, hymnNumber: "\(numberToStore - index)"), songTitle: "song \(numberToStore - index)")))
                                    }
                                })
                            await self.fulfillment(of: [failure, finished, value], timeout: testTimeout)
                            cancellable.cancel()
                        }
                    }
                }
            }
        }
    }
}
