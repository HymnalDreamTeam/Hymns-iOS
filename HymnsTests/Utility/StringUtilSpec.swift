import Quick
import Nimble
import XCTest
@testable import Hymns

// swiftlint:disable identifier_name type_body_length function_body_length
class StringUtilSpec: QuickSpec {

    override func spec() {
        describe("find the Levenshtein Distance") {
            context("includes empty strings") {
                context("one empty string") {
                    it("Distance when there is an empty string should be -1") {
                        expect(StringUtil.levenshteinDistance("", "Levenshtein")).to(equal(-1))
                    }
                }
                context("two empty strings") {
                    it("Distance when there is are two empty strings should be -1") {
                        expect(StringUtil.levenshteinDistance("", "")).to(equal(-1))
                    }
                }
                it("IdenticalStrings") {
                    let distance = StringUtil.levenshteinDistance("hello", "hello")
                    XCTAssertEqual(distance, 0, "Distance between identical strings should be 0")
                }
                it("SingleInsertion") {
                    let distance = StringUtil.levenshteinDistance("book", "books")
                    XCTAssertEqual(distance, 1, "Distance with a single insertion should be 1")
                }
                it("SingleDeletion") {
                    let distance = StringUtil.levenshteinDistance("books", "book")
                    XCTAssertEqual(distance, 1, "Distance with a single deletion should be 1")
                }
                it("SingleSubstitution") {
                    let distance = StringUtil.levenshteinDistance("sale", "pale")
                    XCTAssertEqual(distance, 1, "Distance with a single substitution should be 1")
                }
                it("MultipleEdits") {
                    expect(StringUtil.levenshteinDistance("kitten", "sitting")).to(equal(3))
                    expect(StringUtil.levenshteinDistance("saturday", "sunday")).to(equal(3))
                    expect(StringUtil.levenshteinDistance("Levenshtein", "Distance")).to(equal(10))
                }
                it("MultipleEditsReversed") {
                    expect(StringUtil.levenshteinDistance("sitting", "kitten")).to(equal(3))
                    expect(StringUtil.levenshteinDistance("sunday", "saturday")).to(equal(3))
                    expect(StringUtil.levenshteinDistance("Distance", "Levenshtein")).to(equal(10))
                }
            }
        }
    }
}
