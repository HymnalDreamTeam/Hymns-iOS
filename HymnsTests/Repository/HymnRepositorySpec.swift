import Combine
import Mockingbird
import Nimble
import XCTest
import Quick
@testable import Hymns

class HymnRepositorySpec: QuickSpec {

    override func spec() {
        describe("HymnRepository") {
            let testQueue = DispatchQueue.init(label: "test_queue")
            var converter: ConverterMock!
            var dataStore: HymnDataStoreMock!
            var service: HymnalApiServiceMock!
            var songbaseStore: SongbaseStoreMock!
            var systemUtil: SystemUtilMock!
            var target: HymnsRepository!
            beforeEach {
                converter = mock(Converter.self)
                dataStore = mock(HymnDataStore.self)
                service = mock(HymnalApiService.self)
                songbaseStore = mock(SongbaseStore.self)
                systemUtil = mock(SystemUtil.self)
                target = HymnsRepositoryImpl(converter: converter, dataStore: dataStore, mainQueue: testQueue,
                                             service: service, songbaseStore: songbaseStore, systemUtil: systemUtil)
                given(dataStore.getDatabaseInitializedProperly()) ~> true
                given(dataStore.getHymn(cebuano123)) ~> { _ in
                    Just(nil).mapError({ _ -> ErrorType in
                        // This will never be triggered.
                    }).eraseToAnyPublisher()
                }
            }
            describe("getSongbase") {
                beforeEach {
                    given(songbaseStore.getHymn(bookId: 1, bookIndex: 1)) ~> { _, _  in
                        Just(nil).mapError({ _ -> ErrorType in
                            // This will never be triggered.
                        }).eraseToAnyPublisher()
                    }
                }
                it("should call the songbase store") {
                    let completion = self.expectation(description: "completion received")
                    let value = self.expectation(description: "value received")
                    let cancellable = target.getSongbase(bookId: 1, bookIndex: 1)
                        .print(self.description)
                        .sink(receiveCompletion: { state in
                            completion.fulfill()
                            expect(state).to(equal(.finished))
                        }, receiveValue: { hymn in
                            value.fulfill()
                            expect(hymn).to(beNil())
                        })

                    verify(songbaseStore.getHymn(bookId: 1, bookIndex: 1)).wasCalled(exactly(1))
                    self.wait(for: [completion, value], timeout: testTimeout)
                    cancellable.cancel()
                }
            }
        }
    }
}
