import Combine
import Quick
import Mockingbird
import Nimble
@testable import Hymns

class SongInfoDialogViewModelSpec: QuickSpec {

    override func spec() {
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
                    let expected = [SongInfoViewModel(label: "Category", values: ["Experience of Christ"]),
                                    SongInfoViewModel(label: "Subcategory", values: ["As Food and Drink"]),
                                    SongInfoViewModel(label: "Author", values: ["M. C.", "Titus Ting", "Will Jeng"]),
                                    SongInfoViewModel(label: "Composer", values: ["Traditional melody"]),
                                    SongInfoViewModel(label: "Key", values: ["Ab Major"]),
                                    SongInfoViewModel(label: "Time", values: ["4/4"]),
                                    SongInfoViewModel(label: "Meter", values: ["Peculiar Meter."]),
                                    SongInfoViewModel(label: "Scriptures", values: ["Revelation 22", "Genesis 1:1"]),
                                    SongInfoViewModel(label: "Hymn Code", values: ["5556111233321"])]
                    expect(target.songInfo).to(equal(expected))
                }
            }
        }
    }
}
