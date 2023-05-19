import Combine
import Quick
import Mockingbird
import Nimble
import RealmSwift
@testable import Hymns

class LaunchRouterViewModelSpec: QuickSpec {

    @MainActor
    override func spec() {
        describe("LaunchRouterViewModel") {
            // https://www.vadimbulavin.com/unit-testing-async-code-in-swift/
            let testQueue = DispatchQueue(label: "test_queue")
            var songbaseV3Migrater: SongbaseV3MigraterMock!
            var systemUtil: SystemUtilMock!
            var target: LaunchRouterViewModel!
            beforeEach {
                songbaseV3Migrater = mock(SongbaseV3Migrater.self)
                systemUtil = mock(SystemUtil.self)
                target = LaunchRouterViewModel(backgroundQueue: testQueue, mainQueue: testQueue, songbaseV3Migrater: songbaseV3Migrater, systemUtil: systemUtil)
            }
            describe("delete old database files") {
                context("contains files to delete") {
                    let otherDatabases = ["hymnaldb-v\(HYMN_DATA_STORE_VERISON - 1).sqlite",
                                          "hymnaldb-v\(HYMN_DATA_STORE_VERISON - 1)-wal.sqlite",
                                          "hymnaldb-v\(HYMN_DATA_STORE_VERISON - 1)-shm.sqlite",
                                          "hymnaldb-v\(HYMN_DATA_STORE_VERISON + 1).sqlite",
                                          "hymnaldb-v\(HYMN_DATA_STORE_VERISON + 1)-wal.sqlite",
                                          "hymnaldb-v\(HYMN_DATA_STORE_VERISON + 1)-shm.sqlite"]
                    let currentDatabase = "hymnaldb-v\(HYMN_DATA_STORE_VERISON).sqlite"
                    let otherFiles = ["random file.txt", "random file2.sqlite"]
                    let allFiles = otherDatabases + [currentDatabase] + otherFiles
                    beforeEach {
                        let fileManager = FileManager.default
                        do {
                            let applicationSupportPath = try fileManager.url(for: .applicationSupportDirectory,
                                                                             in: .userDomainMask,
                                                                             appropriateFor: nil, create: true).path
                            allFiles.forEach { file in
                                expect(fileManager.createFile(atPath: "\(applicationSupportPath)/\(file)",
                                                              contents: "file 1".data(using: .utf8))).to(beTrue())
                            }
                            allFiles.forEach { file in
                                expect(fileManager.fileExists(atPath: "\(applicationSupportPath)/\(file)")).to(beTrue())
                            }
                        } catch {
                            fail("Unable to populate file system with files to delete: \(error)")
                        }
                        await target.deleteOldDatabaseFiles()
                    }
                    afterEach {
                        let fileManager = FileManager.default
                        do {
                            let applicationSupportPath = try fileManager.url(for: .applicationSupportDirectory,
                                                                             in: .userDomainMask,
                                                                             appropriateFor: nil, create: true).path
                            try allFiles.forEach { file in
                                let path = "\(applicationSupportPath)/\(file)"
                                if fileManager.fileExists(atPath: path) {
                                    try fileManager.removeItem(atPath: path)
                                }
                            }
                        } catch {
                            fail("Unable to clean file system with files after delete: \(error)")
                        }
                    }
                    it("should delete all files except the current database") {
                        testQueue.sync {
                            let fileManager = FileManager.default
                            do {
                                let applicationSupportPath = try fileManager.url(for: .applicationSupportDirectory,
                                                                                 in: .userDomainMask,
                                                                                 appropriateFor: nil, create: true).path
                                otherDatabases.forEach { otherDatabase in
                                    expect(fileManager.fileExists(atPath: "\(applicationSupportPath)/\(otherDatabase)")).to(beFalse())
                                }
                                otherFiles.forEach { otherDatabase in
                                    expect(fileManager.fileExists(atPath: "\(applicationSupportPath)/\(otherDatabase)")).to(beTrue())
                                }
                                expect(fileManager.fileExists(atPath: "\(applicationSupportPath)/\(currentDatabase)")).to(beTrue())
                            } catch {
                                fail("Unable to assert deletion worked: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
}
