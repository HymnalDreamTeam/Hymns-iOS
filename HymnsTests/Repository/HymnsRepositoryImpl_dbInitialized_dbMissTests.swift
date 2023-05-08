import Combine
import Mockingbird
import XCTest
@testable import Hymns

class HymnsRepositoryImpl_dbInitialized_dbMissTests: XCTestCase {

    let databaseResult = HymnEntityBuilder().title("song title")
        .lyrics([VerseEntity(verseType: .verse, lineStrings: ["line 1", "line 2"])])
        .build()
    let networkResult = Hymn(title: "song title", metaData: [MetaDatum](), lyrics: [Verse(verseType: .verse, verseContent: ["line 1", "line 2"])])
    let expected = UiHymn(hymnIdentifier: cebuano123, title: "song title", lyrics: [VerseEntity(verseType: .verse, lineStrings: ["line 1", "line 2"])])

    var backgroundQueue = DispatchQueue.init(label: "background test queue")
    var converter: ConverterMock!
    var dataStore: HymnDataStoreMock!
    var service: HymnalApiServiceMock!
    var systemUtil: SystemUtilMock!
    var target: HymnsRepository!

    override func setUp() {
        super.setUp()
        converter = mock(Converter.self)
        dataStore = mock(HymnDataStore.self)
        service = mock(HymnalApiService.self)
        systemUtil = mock(SystemUtil.self)
        target = HymnsRepositoryImpl(converter: converter, dataStore: dataStore, mainQueue: backgroundQueue, service: service, systemUtil: systemUtil)
        given(dataStore.getDatabaseInitializedProperly()) ~> true
        given(dataStore.getHymn(cebuano123)) ~> { _ in
            Just(nil).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }
    }

    func test_getHymn_noNetwork() {
        given(systemUtil.isNetworkAvailable()) ~> false
        given(converter.toUiHymn(hymnIdentifier: cebuano123, hymnEntity: nil)) ~> nil

        let completion = expectation(description: "completion received")
        let value = expectation(description: "value received")
        let cancellable = target.getHymn(cebuano123)
            .print(self.description)
            .sink(receiveCompletion: { state in
                completion.fulfill()
                XCTAssertEqual(state, .finished)
            }, receiveValue: { hymn in
                value.fulfill()
                XCTAssertNil(hymn)
            })

        verify(dataStore.getHymn(cebuano123)).wasCalled(exactly(1))
        verify(service.getHymn(any())).wasNeverCalled()
        verify(dataStore.saveHymn(any(HymnEntity.self))).wasNeverCalled()
        verify(dataStore.saveHymn(any(HymnIdEntity.self))).wasNeverCalled()
        wait(for: [completion, value], timeout: testTimeout)
        cancellable.cancel()
    }

    func test_getHymn_networkAvailable_networkError() {
        given(systemUtil.isNetworkAvailable()) ~> true
        given(service.getHymn(cebuano123)) ~> { _ in
            Just(self.networkResult)
                .tryMap({ _ -> Hymn in
                    throw URLError(.badServerResponse)
                })
                .mapError({ _ -> ErrorType in
                    ErrorType.data(description: "forced network error")
                }).eraseToAnyPublisher()
        }

        let completion = expectation(description: "completion received")
        let value = expectation(description: "value received")
        value.expectedFulfillmentCount = 2
        let cancellable = target.getHymn(cebuano123)
            .print(self.description)
            .sink(receiveCompletion: { state in
                completion.fulfill()
                XCTAssertEqual(state, .finished)
            }, receiveValue: { hymn in
                value.fulfill()
                XCTAssertNil(hymn)
            })

        verify(dataStore.getHymn(cebuano123)).wasCalled(exactly(1))
        verify(service.getHymn(cebuano123)).wasCalled(exactly(1))
        verify(dataStore.saveHymn(any(HymnEntity.self))).wasNeverCalled()
        verify(dataStore.saveHymn(any(HymnIdEntity.self))).wasNeverCalled()
        wait(for: [completion, value], timeout: testTimeout)
        cancellable.cancel()
    }

    func test_getHymn_networkAvailable_makeNetworkRequestFalse() {
        given(systemUtil.isNetworkAvailable()) ~> true
        given(converter.toUiHymn(hymnIdentifier: cebuano123, hymnEntity: nil)) ~> nil

        let completion = expectation(description: "completion received")
        let value = expectation(description: "value received")
        let cancellable = target.getHymn(cebuano123, makeNetworkRequest: false)
            .print(self.description)
            .sink(receiveCompletion: { state in
                completion.fulfill()
                XCTAssertEqual(state, .finished)
            }, receiveValue: { hymn in
                value.fulfill()
                XCTAssertNil(hymn)
            })

        verify(dataStore.getHymn(cebuano123)).wasCalled(exactly(1))
        verify(service.getHymn(any())).wasNeverCalled()
        verify(dataStore.saveHymn(any(HymnEntity.self))).wasNeverCalled()
        verify(dataStore.saveHymn(any(HymnIdEntity.self))).wasNeverCalled()
        wait(for: [completion, value], timeout: testTimeout)
        cancellable.cancel()
    }

    func test_getHymn_networkAvailable_resultsSuccessful() {
        given(systemUtil.isNetworkAvailable()) ~> true
        given(service.getHymn(cebuano123)) ~> {  _ in
            return Just(self.networkResult).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }
        givenSwift(dataStore.saveHymn(databaseResult)) ~> 2
        given(converter.toHymnEntity(hymn: self.networkResult)) ~> self.databaseResult
        given(converter.toUiHymn(hymnIdentifier: cebuano123, hymnEntity: self.databaseResult)) ~> self.expected

        let completion = expectation(description: "completion received")
        let value = expectation(description: "value received")
        value.expectedFulfillmentCount = 2
        var valueCount = 0
        let cancellable = target.getHymn(cebuano123)
            .print(self.description)
            .sink(receiveCompletion: { state in
                completion.fulfill()
                XCTAssertEqual(state, .finished)
            }, receiveValue: { hymn in
                value.fulfill()
                valueCount += 1
                if valueCount == 1 {
                    XCTAssertNil(hymn)
                } else if valueCount == 2 {
                    XCTAssertEqual(self.expected, hymn!)
                } else {
                    XCTFail("receiveValue should only be called twice")
                }
            })

        verify(dataStore.getHymn(cebuano123)).wasCalled(exactly(1))
        verify(service.getHymn(cebuano123)).wasCalled(exactly(1))
        verify(dataStore.saveHymn(self.databaseResult)).wasCalled(exactly(1))
        verify(dataStore.saveHymn(HymnIdEntity(hymnIdentifier: cebuano123, songId: 2))).wasCalled(exactly(1))
        wait(for: [completion, value], timeout: testTimeout)
        cancellable.cancel()
    }

    func test_getHymn_networkConversionError() {
        given(systemUtil.isNetworkAvailable()) ~> true
        given(service.getHymn(cebuano123)) ~> {  _ in
            Just(self.networkResult).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }
        given(converter.toHymnEntity(hymn: self.networkResult)) ~> {_ in
            throw TypeConversionError.init(triggeringError: ErrorType.parsing(description: "failed to convert!"))
        }

        let completion = expectation(description: "completion received")
        let value = expectation(description: "value received")
        value.expectedFulfillmentCount = 2
        let cancellable = target.getHymn(cebuano123)
            .print(self.description)
            .sink(receiveCompletion: { state in
                completion.fulfill()
                XCTAssertEqual(state, .finished)
            }, receiveValue: { hymn in
                value.fulfill()
                XCTAssertNil(hymn)
            })

        verify(dataStore.getHymn(cebuano123)).wasCalled(exactly(1))
        verify(service.getHymn(cebuano123)).wasCalled(exactly(1))
        verify(dataStore.saveHymn(any(HymnEntity.self))).wasNeverCalled()
        verify(dataStore.saveHymn(any(HymnIdEntity.self))).wasNeverCalled()
        wait(for: [completion, value], timeout: testTimeout)
        cancellable.cancel()
    }
}
