import Combine
import Quick
import Mockingbird
import Nimble
import RealmSwift
@testable import Hymns

class FavoriteStoreRealmImplSpec: QuickSpec {

    @MainActor
    override func spec() {
        describe("using an in-memory realm") {
            var inMemoryRealm: Realm!
            var target: FavoriteStoreRealmImpl!
            beforeEach {
                // Don't worry about force_try in tests.
                // swiftlint:disable:next force_try
                inMemoryRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "FavoriteStoreRealmImplSpec"))
                target = FavoriteStoreRealmImpl(realm: inMemoryRealm)
            }
            afterEach {
                // Don't worry about force_try in tests.
                // swiftlint:disable:next force_try
                try! inMemoryRealm.write {
                    inMemoryRealm.deleteAll()
                }
                inMemoryRealm.invalidate()
            }
            context("store a few favorites") {
                beforeEach {
                    target.storeFavorite(FavoriteEntity(hymnIdentifier: classic1151, songTitle: "Hymn 1151"))
                    target.storeFavorite(FavoriteEntity(hymnIdentifier: newSong145, songTitle: "Hymn: Jesus shall reign where\\u2019er the sun"))
                    target.storeFavorite(FavoriteEntity(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014"))
                }
                describe("get the list of all favorites") {
                    it("should get all favorited songs") {
                        let failure = self.expectation(description: "Invalid.failure")
                        failure.isInverted = true
                        let finished = self.expectation(description: "Invalid.finished")
                        // finished should not be called because this is a self-updating publisher.
                        finished.isInverted = true
                        let value = self.expectation(description: "Invalid.receiveValue")

                        let cancellable = target.favorites()
                            .sink(receiveCompletion: { (completion: Subscribers.Completion<ErrorType>) -> Void in
                                switch completion {
                                case .failure:
                                    failure.fulfill()
                                case .finished:
                                    finished.fulfill()
                                }
                                return
                            }, receiveValue: { entities in
                                value.fulfill()
                                expect(entities).to(equal([FavoriteEntity(hymnIdentifier: classic1151, songTitle: "Hymn 1151"),
                                                           FavoriteEntity(hymnIdentifier: newSong145, songTitle: "Hymn: Jesus shall reign where\\u2019er the sun"),
                                                           FavoriteEntity(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014")]))
                            })
                        self.wait(for: [failure, finished, value], timeout: testTimeout)
                        cancellable.cancel()
                    }
                    it("cebuano123 should be favorited") {
                        let failure = self.expectation(description: "Invalid.failure")
                        failure.isInverted = true
                        let finished = self.expectation(description: "Invalid.finished")
                        // finished should not be called because this is a self-updating publisher.
                        finished.isInverted = true
                        let value = self.expectation(description: "Invalid.receiveValue")

                        let cancellable = target.isFavorite(hymnIdentifier: cebuano123)
                            .sink(receiveCompletion: { (completion: Subscribers.Completion<ErrorType>) -> Void in
                                switch completion {
                                case .failure:
                                    failure.fulfill()
                                case .finished:
                                    finished.fulfill()
                                }
                                return
                            }, receiveValue: { isFavorite in
                                value.fulfill()
                                expect(isFavorite).to(beTrue())
                            })
                        self.wait(for: [failure, finished, value], timeout: testTimeout)
                        cancellable.cancel()
                    }
                    context("favorites status changes") {
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
                            cancellable = target.isFavorite(hymnIdentifier: cebuano123)
                                .sink(receiveCompletion: { (completion: Subscribers.Completion<ErrorType>) -> Void in
                                    switch completion {
                                    case .failure:
                                        failure.fulfill()
                                    case .finished:
                                        finished.fulfill()
                                    }
                                    return
                                }, receiveValue: { isFavorite in
                                    value.fulfill()
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
                        it("the correct callbacks should be called") {
                            target.deleteFavorite(primaryKey: FavoriteEntity.createPrimaryKey(hymnIdentifier: cebuano123))
                            self.wait(for: [failure, finished, value], timeout: testTimeout)
                            expect(cancellable).toNot(beNil())
                            cancellable!.cancel()
                        }
                    }
                }
            }
        }
    }
}
