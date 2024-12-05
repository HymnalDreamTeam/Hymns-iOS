import Combine
import Mockingbird
import Nimble
import Quick
@testable import Hymns

// swiftlint:disable type_name
class DisplayHymnContainerViewModelSpec: QuickSpec {

    override class func spec() {
        describe("DisplayHymnContainerViewModelSpec") {
            // https://www.vadimbulavin.com/unit-testing-async-code-in-swift/
            let testQueue = DispatchQueue(label: "test_queue")
            var dataStore: HymnDataStoreMock!
            var target: DisplayHymnContainerViewModel!
            beforeEach {
                dataStore = mock(HymnDataStore.self)
                given(dataStore.getHymns(by: .classic)) ~> { _  in
                    Just([SongResultEntity(hymnType: .classic, hymnNumber: "1333"),
                          SongResultEntity(hymnType: .classic, hymnNumber: "2"),
                          SongResultEntity(hymnType: .classic, hymnNumber: "3"),
                          SongResultEntity(hymnType: .classic, hymnNumber: "13"),
                          SongResultEntity(hymnType: .classic, hymnNumber: "13a"),
                          SongResultEntity(hymnType: .classic, hymnNumber: "14"),
                          SongResultEntity(hymnType: .classic, hymnNumber: "113"),
                          SongResultEntity(hymnType: .classic, hymnNumber: "1330")]).mapError({ _ -> ErrorType in
                        // This will never be triggered.
                    }).eraseToAnyPublisher()
                }
                target = DisplayHymnContainerViewModel(hymnToDisplay: HymnIdentifier(hymnType: .classic, hymnNumber: "13"),
                                                       backgroundQueue: testQueue, dataStore: dataStore, mainQueue: testQueue)
            }
            context("hymn numbers found") {
                beforeEach {
                    target.populateHymns()
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("hymns should contain all the classic hymns") {
                    expect(target.hymns).to(haveCount(7))
                    expect(target.hymns![0].identifier).to(equal(HymnIdentifier(hymnType: .classic, hymnNumber: "2")))
                    expect(target.hymns![1].identifier).to(equal(HymnIdentifier(hymnType: .classic, hymnNumber: "3")))
                    expect(target.hymns![2].identifier).to(equal(HymnIdentifier(hymnType: .classic, hymnNumber: "13")))
                    expect(target.hymns![3].identifier).to(equal(HymnIdentifier(hymnType: .classic, hymnNumber: "14")))
                    expect(target.hymns![4].identifier).to(equal(HymnIdentifier(hymnType: .classic, hymnNumber: "113")))
                    expect(target.hymns![5].identifier).to(equal(HymnIdentifier(hymnType: .classic, hymnNumber: "1330")))
                    expect(target.hymns![6].identifier).to(equal(HymnIdentifier(hymnType: .classic, hymnNumber: "1333")))
                }
                it("current hymn should be at the correct index") {
                    expect(target.currentHymn).to(equal(2))
                }
            }
            context("hymn numbers not found") {
                beforeEach {
                    given(dataStore.getHymns(by: .classic)) ~> { _  in
                        Just([SongResultEntity]()).mapError({ _ -> ErrorType in
                            // This will never be triggered.
                        }).eraseToAnyPublisher()
                    }
                    target.populateHymns()
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("hymns should contain only the loaded song") {
                    expect(target.hymns).to(haveCount(1))
                    expect(target.hymns![0].identifier.hymnType).to(equal(HymnType.classic))
                    expect(target.hymns![0].identifier.hymnNumber).to(equal("13"))
                }
                it("current hymn should be 0") {
                    expect(target.currentHymn).to(equal(0))
                }
            }
            context("with non-number hymn number") {
                beforeEach {
                    target = DisplayHymnContainerViewModel(hymnToDisplay: HymnIdentifier(hymnType: .classic, hymnNumber: "abc"),
                                                           backgroundQueue: testQueue, dataStore: dataStore, mainQueue: testQueue)
                    target.populateHymns()
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("hymns should contain only the loaded song") {
                    expect(target.hymns).to(haveCount(1))
                    expect(target.hymns![0].identifier.hymnType).to(equal(HymnType.classic))
                    expect(target.hymns![0].identifier.hymnNumber).to(equal("abc"))
                }
                it("current hymn should be 0") {
                    expect(target.currentHymn).to(equal(0))
                }
            }
            context("with negative hymn number") {
                beforeEach {
                    target = DisplayHymnContainerViewModel(hymnToDisplay: HymnIdentifier(hymnType: .classic, hymnNumber: "-1"),
                                                           backgroundQueue: testQueue, dataStore: dataStore, mainQueue: testQueue)
                    target.populateHymns()
                    testQueue.sync {}
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("hymns should contain only the loaded song") {
                    expect(target.hymns).to(haveCount(1))
                    expect(target.hymns![0].identifier.hymnType).to(equal(HymnType.classic))
                    expect(target.hymns![0].identifier.hymnNumber).to(equal("-1"))
                }
                it("current hymn should be 0") {
                    expect(target.currentHymn).to(equal(0))
                }
            }
            context("data store error") {
                beforeEach {
                    given(dataStore.getHymns(by: .classic)) ~> { _  in
                        Just([SongResultEntity]())
                            .tryMap({ _ -> [SongResultEntity] in
                                throw URLError(.badURL)
                            }).mapError({ _ -> ErrorType in
                                    .data(description: "forced data error")
                            }).eraseToAnyPublisher()
                    }
                    target.populateHymns()
                    testQueue.sync {}
                    testQueue.sync {}
                }
                it("hymns should contain only the loaded song") {
                    expect(target.hymns).to(haveCount(1))
                    expect(target.hymns![0].identifier.hymnType).to(equal(HymnType.classic))
                    expect(target.hymns![0].identifier.hymnNumber).to(equal("13"))
                }
                it("current hymn should be 0") {
                    expect(target.currentHymn).to(equal(0))
                }
            }
        }
    }
}
