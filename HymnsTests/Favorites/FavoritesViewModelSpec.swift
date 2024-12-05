import Combine
import Mockingbird
import Nimble
import Quick
@testable import Hymns

class FavoritesViewModelSpec: QuickSpec {

    override class func spec() {

        // https://www.vadimbulavin.com/unit-testing-async-code-in-swift/
        let testQueue = DispatchQueue(label: "test_queue")
        var favoriteStore: FavoriteStoreMock!
        var target: FavoritesViewModel!

        describe("fetching favorites") {
            beforeEach {
                favoriteStore = mock(FavoriteStore.self)
                target = FavoritesViewModel(favoriteStore: favoriteStore, mainQueue: testQueue)
            }
            context("initial state") {
                it("favorites should be nil") {
                    expect(target.favorites).to(beNil())
                }
            }
            context("data store error") {
                beforeEach {
                    given(favoriteStore.favorites()) ~> {
                        Just([FavoriteEntity]())
                            .tryMap({ _ -> [FavoriteEntity] in
                                throw URLError(.badServerResponse)
                            }).mapError({ _ -> ErrorType in
                                .data(description: "forced data error")
                            }).eraseToAnyPublisher()
                    }
                    target.fetchFavorites()
                    testQueue.sync {}
                }
                it("favorites should be empty") {
                    expect(target.favorites).to(beEmpty())
                }
            }
            context("data store empty") {
                beforeEach {
                    given(favoriteStore.favorites()) ~> {
                        Just([FavoriteEntity]()).mapError({ _ -> ErrorType in
                            // This will never be triggered.
                        }).eraseToAnyPublisher()
                    }
                    target.fetchFavorites()
                    testQueue.sync {}
                }
                it("favorites should be empty") {
                    expect(target.favorites).to(beEmpty())
                }
            }
            context("data store results") {
                let favoriteEntities = [FavoriteEntity(hymnIdentifier: classic1109, songTitle: "Hymn 1109"),
                                        FavoriteEntity(hymnIdentifier: cebuano123, songTitle: "Cebuano 123")]
                beforeEach {
                    given(favoriteStore.favorites()) ~> {
                        Just(favoriteEntities).mapError({ _ -> ErrorType in
                            // This will never be triggered.
                        }).eraseToAnyPublisher()
                    }
                    target.fetchFavorites()
                    testQueue.sync {}
                }
                it("should have the correct view models") {
                    expect(target.favorites).to(haveCount(2))
                    expect(target.favorites![0].title).to(equal("Hymn 1109"))
                    expect(target.favorites![1].title).to(equal("Cebuano 123"))
                }
            }
        }
    }
}
