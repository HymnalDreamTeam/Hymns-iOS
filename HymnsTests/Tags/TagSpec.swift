import Combine
import Mockingbird
import Nimble
import Quick
@testable import Hymns

class TagSpec: QuickSpec {
    override func spec() {
        describe("copy") {
            describe("Tag") {
                var target: Tag!
                beforeEach {
                    target = Tag(hymnIdentifier: HymnIdentifier(hymnType: .blueSongbook, hymnNumber: "12"),
                                 songTitle: "Blue Songbook 12", tag: "T1", color: .red)
                }
                it("copies all the fields") {
                    expect(target.copy()).to(equal(target))
                }
            }
            describe("TagEntity") {
                var target: TagEntity!
                beforeEach {
                    target = TagEntity(tagObject: Tag(hymnIdentifier: HymnIdentifier(hymnType: .blueSongbook, hymnNumber: "12"),
                                                      songTitle: "Blue Songbook 12", tag: "T1", color: .red),
                                       created: Date(julianDay: 11)!)
                }
                it("copies all the fields") {
                    expect(target.copy().tagObject).to(equal(target.tagObject))
                    expect(target.copy().created).to(equal(target.created))
                }
            }
        }
    }
}
