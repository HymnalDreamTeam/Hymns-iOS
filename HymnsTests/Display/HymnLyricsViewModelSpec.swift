import Combine
import Quick
import Mockingbird
import Nimble
@testable import Hymns

class HymnLyricsViewModelSpec: QuickSpec {

    override class func spec() {
        describe("HymnLyricsViewModel initialized") {
            var target: HymnLyricsViewModel!
            context("with nil lyrics") {
                beforeEach {
                    target = HymnLyricsViewModel(hymnToDisplay: classic1151, lyrics: nil)
                }
                it("should return nil view model") {
                    expect(target).to(beNil())
                }
            }
            context("with empty lyrics") {
                beforeEach {
                    target = HymnLyricsViewModel(hymnToDisplay: classic1151, lyrics: [VerseEntity]())
                }
                it("should return nil view model") {
                    expect(target).to(beNil())
                }
            }
            // Other cases will need to rely on snapshot tests since HymnLyricsViewModel creates an
            // attriuted string, which is visual by nature, and thus difficult to test via unit tests.
        }
    }
}
