import Combine
import Mockingbird
import Nimble
import Quick
@testable import Hymns

// swiftlint:disable type_name
class DisplayHymnContainerViewModelSpec: QuickSpec {

    override func spec() {
        describe("DisplayHymnContainerViewModelSpec") {
            var target: DisplayHymnContainerViewModel!
            context("with continuous hymn type") {
                beforeEach {
                    target = DisplayHymnContainerViewModel(hymnToDisplay: HymnIdentifier(hymnType: .classic, hymnNumber: "13"))
                    target.populateHymns()
                }
                it("hymns should contain all the classic hymns") {
                    expect(target.hymns).to(haveCount(1360))
                    for num in 0..<1360 {
                        expect(target.hymns![num].identifier.hymnType).to(equal(HymnType.classic))
                        expect(target.hymns![num].identifier.hymnNumber).to(equal("\(num + 1)"))
                    }
                }
                it("current hymn should be input song - 1 (list is 0-indexed)") {
                    expect(target.currentHymn).to(equal(12))
                }
            }
            context("with non-continuous hymn type") {
                beforeEach {
                    target = DisplayHymnContainerViewModel(hymnToDisplay: HymnIdentifier(hymnType: .newTune, hymnNumber: "13"))
                    target.populateHymns()
                }
                it("hymns should contain only the loaded song") {
                    expect(target.hymns).to(haveCount(1))
                    expect(target.hymns![0].identifier.hymnType).to(equal(HymnType.newTune))
                    expect(target.hymns![0].identifier.hymnNumber).to(equal("13"))
                }
                it("current hymn should be 0") {
                    expect(target.currentHymn).to(equal(0))
                }
            }
            context("with hymn number greater than max number") {
                beforeEach {
                    target = DisplayHymnContainerViewModel(hymnToDisplay: HymnIdentifier(hymnType: .classic, hymnNumber: "6550"))
                    target.populateHymns()
                }
                it("hymns should contain only the loaded song") {
                    expect(target.hymns).to(haveCount(1))
                    expect(target.hymns![0].identifier.hymnType).to(equal(HymnType.classic))
                    expect(target.hymns![0].identifier.hymnNumber).to(equal("6550"))
                }
                it("current hymn should be 0") {
                    expect(target.currentHymn).to(equal(0))
                }
            }
            context("with non-number hymn number") {
                beforeEach {
                    target = DisplayHymnContainerViewModel(hymnToDisplay: HymnIdentifier(hymnType: .classic, hymnNumber: "abc"))
                    target.populateHymns()
                }
                it("hymns should contain only the loaded song") {
                    expect(target.hymns).to(haveCount(1))
                    expect(target.hymns![0].identifier.hymnType).to(equal(HymnType.classic))
                    expect(target.hymns![0].identifier.hymnNumber).to(equal("abc"))
                }
                it("current hymn should be 0") {
                    expect(target.currentHymn).to(equal(0))
                }
            }
            context("with negative hymn number") {
                beforeEach {
                    target = DisplayHymnContainerViewModel(hymnToDisplay: HymnIdentifier(hymnType: .classic, hymnNumber: "-1"))
                    target.populateHymns()
                }
                it("hymns should contain only the loaded song") {
                    expect(target.hymns).to(haveCount(1))
                    expect(target.hymns![0].identifier.hymnType).to(equal(HymnType.classic))
                    expect(target.hymns![0].identifier.hymnNumber).to(equal("-1"))
                }
                it("current hymn should be 0") {
                    expect(target.currentHymn).to(equal(0))
                }
            }
        }
    }
}
