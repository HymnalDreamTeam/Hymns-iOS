import Combine
import Quick
import Mockingbird
import Nimble
import RealmSwift
@testable import Hymns

class TagStoreRealmImplSpec: QuickSpec {
    override func spec() {
        describe("using an in-memory realm") {
            var inMemoryRealm: Realm!
            var target: TagStoreRealmImpl!
            beforeEach {
                // Don't worry about force_try in tests.
                // swiftlint:disable:next force_try
                inMemoryRealm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "TagStoreMock"))
                target = TagStoreRealmImpl(realm: inMemoryRealm)
            }
            afterEach {
                // Don't worry about force_try in tests.
                // swiftlint:disable:next force_try
                try! inMemoryRealm.write {
                    inMemoryRealm.deleteAll()
                }
                inMemoryRealm.invalidate()
            }
            context("store a few tags") {
                beforeEach {
                    target.storeTag(TagEntity(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Christ"))
                    target.storeTag(TagEntity(hymnIdentifier: newSong145, songTitle: "Hymn: Jesus shall reign where\\u2019er the sun", tag: "Bread and wine"))
                    target.storeTag(TagEntity(hymnIdentifier: cebuano123, songTitle: "Naghigda sa lubong\\u2014", tag: "Table"))
                }
                describe("getting one hymn's tags after storing multiple tags for that hymn") {
                    beforeEach {
                        target.storeTag(TagEntity(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Is"))
                        target.storeTag(TagEntity(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Life"))
                        target.storeTag(TagEntity(hymnIdentifier: classic1151, songTitle: "Hymn 1151", tag: "Peace"))
                    }
                    it("should contain a query number matching the number of tags for that hymn") {
                        let resultsOfQuery = target.getTagsForHymn(hymnIdentifier: classic1151)
                        expect(resultsOfQuery).to(equal(["Christ", "Peace", "Life", "Is"]))
                    }
                }
                describe("deleting a tag") {
                    it("should delete the tag") {
                        let queryBeforeDelete = target.getSongsByTag("Table")
                        expect(queryBeforeDelete).to(haveCount(1))
                        target.deleteTag(primaryKey: TagEntity.createPrimaryKey(hymnIdentifier: cebuano123, tag: ""), tag: "Table")
                        let queryAfterDelete = target.getSongsByTag("Table")
                        expect(queryAfterDelete).to(haveCount(0))
                    }
                }
                describe("getting songs for a tag") {
                    beforeEach {
                        target.storeTag(TagEntity(hymnIdentifier: classic500, songTitle: "Hymn 500", tag: "Christ"))
                        target.storeTag(TagEntity(hymnIdentifier: classic1109, songTitle: "Hymn 1109", tag: "Christ"))
                        target.storeTag(TagEntity(hymnIdentifier: cebuano123, songTitle: "Cebuano 123", tag: "Christ"))
                    }
                    it("should return the correctt songs") {
                        let actual = target.getSongsByTag("Christ")
                        expect(actual).to(haveCount(4))
                        expect(actual[0].title).to(equal("Hymn 1151"))
                        expect(actual[1].title).to(equal("Cebuano 123"))
                        expect(actual[2].title).to(equal("Hymn 1109"))
                        expect(actual[3].title).to(equal("Hymn 500"))
                    }
                }
            }
        }
    }
}
