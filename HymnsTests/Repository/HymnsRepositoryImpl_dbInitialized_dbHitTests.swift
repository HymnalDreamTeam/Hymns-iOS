import Combine
import Mockingbird
import XCTest
@testable import Hymns

class HymnsRepositoryImpl_dbInitialized_dbHitTests: XCTestCase {

    let databaseResult = HymnReference(
        hymnIdEntity: HymnIdEntity(hymnIdentifier: cebuano123, songId: 3),
        hymnEntity: HymnEntityBuilder().title("song title")
            .lyrics([VerseEntity(verseType: .verse, lineStrings: ["line 1", "line 2"])])
            .build())
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
            Just(self.databaseResult).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }
    }

    func test_getHymn_resultsCached() {
        given(systemUtil.isNetworkAvailable()) ~> false
        given(converter.toUiHymn(hymnIdentifier: databaseResult.hymnIdEntity.hymnIdentifier!, hymnEntity: databaseResult.hymnEntity)) ~> self.expected

        var set = Set<AnyCancellable>()
        // Make one request to store it the memcache.
        target.getHymn(cebuano123)
            .print(self.description)
            .sink(receiveValue: { _ in })
            .store(in: &set)

        backgroundQueue.sync {}

        // Clear all invocations on the mock.
        clearInvocations(on: dataStore)
        clearInvocations(on: service)

        // Verify you still get the same result but without calling the API.
        let completion = expectation(description: "completion received")
        let value = expectation(description: "value received")
        let cancellable = target.getHymn(cebuano123)
            .print(self.description)
            .sink(receiveCompletion: { state in
                completion.fulfill()
                XCTAssertEqual(state, .finished)
            }, receiveValue: { hymn in
                value.fulfill()
                XCTAssertEqual(self.expected, hymn!)
            })

        verify(dataStore.getHymn(any())).wasNeverCalled()
        verify(service.getHymn(any())).wasNeverCalled()
        verify(dataStore.saveHymn(any(HymnEntity.self))).wasNeverCalled()
        verify(dataStore.saveHymn(any(HymnIdEntity.self))).wasNeverCalled()
        wait(for: [completion, value], timeout: testTimeout)
        cancellable.cancel()
    }

    func test_getHymn_noNetwork() {
        given(dataStore.getHymn(cebuano123)) ~> { _ in
            Just(self.databaseResult).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).subscribe(on: self.backgroundQueue).eraseToAnyPublisher()
            // Test asynchronous data store call as well to make sure the loading values are being dropped
        }
        given(systemUtil.isNetworkAvailable()) ~> false
        given(converter.toUiHymn(hymnIdentifier: databaseResult.hymnIdEntity.hymnIdentifier!, hymnEntity: databaseResult.hymnEntity)) ~> self.expected

        let completion = expectation(description: "completion received")
        let value = expectation(description: "value received")
        let cancellable = target.getHymn(cebuano123)
            .print(self.description)
            .sink(receiveCompletion: { state in
                completion.fulfill()
                XCTAssertEqual(state, .finished)
            }, receiveValue: { hymn in
                value.fulfill()
                XCTAssertEqual(self.expected, hymn!)
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
        given(service.getHymn(cebuano123)) ~> { _ in
            Just(self.networkResult).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }
        given(converter.toUiHymn(hymnIdentifier: databaseResult.hymnIdEntity.hymnIdentifier!, hymnEntity: databaseResult.hymnEntity)) ~> self.expected
        given(converter.toHymnEntity(hymn: self.networkResult)) ~> self.databaseResult.hymnEntity

        let completion = expectation(description: "completion received")
        let value = expectation(description: "value received")
//        value.expectedFulfillmentCount = 2
        let cancellable = target.getHymn(cebuano123)
            .print(self.description)
            .sink(receiveCompletion: { state in
                completion.fulfill()
                XCTAssertEqual(state, .finished)
            }, receiveValue: { hymn in
                value.fulfill()
                XCTAssertEqual(self.expected, hymn!)
            })

        verify(dataStore.getHymn(cebuano123)).wasCalled(exactly(1))
        verify(service.getHymn(any())).wasNeverCalled()
//        TODO: uncomment when we start hitting the network to reconcile/combine hymn results
//        verify(service.getHymn(cebuano123)).wasCalled(exactly(1))
//        verify(dataStore.saveHymn(any())).wasNeverCalled() // Database result unchanged after network update, so don't write to database.
        wait(for: [completion, value], timeout: testTimeout)
        cancellable.cancel()
    }

    func test_getHymn_databaseConversionError_noNetwork() {
        given(systemUtil.isNetworkAvailable()) ~> false
        given(converter.toUiHymn(hymnIdentifier: databaseResult.hymnIdEntity.hymnIdentifier!, hymnEntity: databaseResult.hymnEntity)) ~> { _, _ in
            throw TypeConversionError.init(triggeringError: ErrorType.parsing(description: "failed to convert!"))
        }

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

    func test_getHymn_databaseConversionNil_networkAvailable() {
        given(systemUtil.isNetworkAvailable()) ~> true
        given(service.getHymn(cebuano123)) ~> { _ in
            Just(self.networkResult).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }
        given(converter.toUiHymn(hymnIdentifier: databaseResult.hymnIdEntity.hymnIdentifier!, hymnEntity: databaseResult.hymnEntity)) ~> nil
        given(converter.toHymnEntity(hymn: self.networkResult)) ~> self.databaseResult.hymnEntity

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
        // Database conversion was mocked to return nil, but the database value returned by the mock data store is still the same as the value returned by the
        // mock network. Therefore, the actual data didn't change so we do not perform any kind of update to the data store.
        verify(dataStore.saveHymn(any(HymnEntity.self))).wasNeverCalled()
        verify(dataStore.saveHymn(any(HymnIdEntity.self))).wasNeverCalled()
        wait(for: [completion, value], timeout: testTimeout)
        cancellable.cancel()
    }

    func test_getHymn_databaseConversionError_networkAvailable_resultsSuccessful() {
        givenSwift(dataStore.saveHymn(self.databaseResult.hymnEntity)) ~> 3
        given(systemUtil.isNetworkAvailable()) ~> true
        given(service.getHymn(cebuano123)) ~> { _ in
            return Just(self.networkResult).mapError({ _ -> ErrorType in
                // This will never be triggered.
            }).eraseToAnyPublisher()
        }
        given(converter.toHymnEntity(hymn: self.networkResult)) ~> self.databaseResult.hymnEntity
        given(converter.toUiHymn(hymnIdentifier: databaseResult.hymnIdEntity.hymnIdentifier!, hymnEntity: databaseResult.hymnEntity)) ~> sequence(of: { _, _ in
            throw TypeConversionError.init(triggeringError: ErrorType.parsing(description: "failed to convert!"))
        }, { _, _ in
            return self.expected
        })

        let completion = expectation(description: "completion received")
        let value = expectation(description: "value received")
        let cancellable = target.getHymn(cebuano123)
            .print(self.description)
            .sink(receiveCompletion: { state in
                completion.fulfill()
                XCTAssertEqual(state, .finished)
            }, receiveValue: { hymn in
                value.fulfill()
                XCTAssertEqual(self.expected, hymn!)
            })

        verify(dataStore.getHymn(cebuano123)).wasCalled(exactly(1))
        verify(service.getHymn(cebuano123)).wasCalled(exactly(1))
        verify(dataStore.saveHymn(self.databaseResult.hymnEntity)).wasCalled(exactly(1))
        verify(dataStore.saveHymn(self.databaseResult.hymnIdEntity)).wasCalled(exactly(1))
        wait(for: [completion, value], timeout: testTimeout)
        cancellable.cancel()
    }
}
