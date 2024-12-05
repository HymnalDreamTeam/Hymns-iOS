import Combine
import Quick
import Mockingbird
import Nimble
@testable import Hymns

class VerseLineViewModelSpec: QuickSpec {

    override class func spec() {
        describe("VerseLineViewModel") {
            var target: VerseLineViewModel!
            context("with verse type as verse") {
                beforeEach {
                    target = VerseLineViewModel(verseType: .verse, verseNumber: "one",
                                                lineEntity: LineEntity(lineContent: "content"))
                }
                it ("should set the font size to user defaults font size") {
                    expect(target.fontSize).to(equal(15))
                }
                it ("should set italicized to false") {
                    expect(target.isItalicized).to(beFalse())
                }
                it ("should not have transliteration") {
                    expect(target.transliteration).to(beNil())
                }
            }
            context("with verse type as chorus") {
                beforeEach {
                    target = VerseLineViewModel(verseType: .chorus, lineEntity: LineEntity(lineContent: "content"))
                }
                it ("should set the font size to user defaults font size") {
                    expect(target.fontSize).to(equal(15))
                }
                it ("should set italicized to false") {
                    expect(target.isItalicized).to(beFalse())
                }
            }
            context("with verse type as note") {
                beforeEach {
                    target = VerseLineViewModel(verseType: .note, lineEntity: LineEntity(lineContent: "content"))
                }
                it ("should set the font size to 70% of the user defaults font size") {
                    expect(target.fontSize).to(equal(10.5))
                }
                it ("should set italicized to true") {
                    expect(target.isItalicized).to(beTrue())
                }
            }
        }
    }
}
