import Combine
import Mockingbird
import Nimble
import Quick
@testable import Hymns

class RecengSongSpec: QuickSpec {
    override class func spec() {
        describe("copy") {
            var target: RecentSong!
            beforeEach {
                target = RecentSong(hymnIdentifier: HymnIdentifier(hymnType: .blueSongbook, hymnNumber: "12"), songTitle: "Blue Songbook 12")
            }
            it("copies all the fields") {
                expect(target.copy()).to(equal(target))
            }
        }
    }
}
