import Combine
import Mockingbird
import Nimble
import Quick
@testable import Hymns

class FavoriteEntitySpec: QuickSpec {

    override func spec() {

        var target: FavoriteEntity!

        describe("copy") {
            beforeEach {
                target = FavoriteEntity(hymnIdentifier: HymnIdentifier(hymnType: .blueSongbook, hymnNumber: "12"), songTitle: "Blue Songbook 12")
            }
            it("copies all the fields") {
                expect(target.copy()).to(equal(target))
            }
        }
    }
}
