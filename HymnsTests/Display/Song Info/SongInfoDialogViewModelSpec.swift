import Combine
import Quick
import Mockingbird
import Nimble
@testable import Hymns

class SongInfoDialogViewModelSpec: QuickSpec {

    override class func spec() {
        describe("SongInfoDialogViewModel") {
            var target: SongInfoDialogViewModel!
            context("no info to show") {
                let hymn = UiHymn(hymnIdentifier: PreviewHymnIdentifiers.hymn40, title: "", lyrics: nil)
                beforeEach {
                    target = SongInfoDialogViewModel(hymnToDisplay: classic1151, hymn: hymn)
                }
                it("should produce a null view model") {
                    expect(target).to(beNil())
                }
            }
            context("info exists but all empty") {
                let hymn = UiHymn(hymnIdentifier: PreviewHymnIdentifiers.hymn40, title: "", lyrics: nil,
                                  category: "", subcategory: "", author: "", composer: "",
                                  key: "", time: "", meter: "", scriptures: "", hymnCode: "")
                beforeEach {
                    target = SongInfoDialogViewModel(hymnToDisplay: classic1151, hymn: hymn)
                }
                it("should produce a null view model") {
                    expect(target).to(beNil())
                }
            }
            context("all info exists") {
                let hymn = UiHymn(hymnIdentifier: PreviewHymnIdentifiers.hymn40, title: "", lyrics: nil,
                                  category: "Experience of Christ", subcategory: "As Food and Drink", author: "M. C. ;Titus Ting; ; ;;Will Jeng",
                                  composer: "Traditional melody", key: "Ab Major", time: "4/4", meter: "Peculiar Meter.",
                                  scriptures: "Revelation 22;Genesis 1:1", hymnCode: "5556111233321")

                beforeEach {
                    target = SongInfoDialogViewModel(hymnToDisplay: classic1151, hymn: hymn)
                }
                it("song info should be filled") {
                    expect(target.songInfo).to(haveCount(9))
                    let expected = [SongInfoViewModel(type: .category, values: ["Experience of Christ"]),
                                    SongInfoViewModel(type: .subcategory, values: ["As Food and Drink"]),
                                    SongInfoViewModel(type: .author, values: ["M. C.", "Titus Ting", "Will Jeng"]),
                                    SongInfoViewModel(type: .composer, values: ["Traditional melody"]),
                                    SongInfoViewModel(type: .key, values: ["Ab Major"]),
                                    SongInfoViewModel(type: .time, values: ["4/4"]),
                                    SongInfoViewModel(type: .meter, values: ["Peculiar Meter."]),
                                    SongInfoViewModel(type: .scriptures, values: ["Revelation 22", "Genesis 1:1"]),
                                    SongInfoViewModel(type: .hymnCode, values: ["5556111233321"])]
                    expect(target.songInfo).to(equal(expected))
                }
            }
        }
    }
}
