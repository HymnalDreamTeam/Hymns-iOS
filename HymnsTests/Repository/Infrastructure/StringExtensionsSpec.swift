import Quick
import Nimble
import XCTest
@testable import Hymns

class StringExtensionsSpec: QuickSpec {

    override class func spec() {
        describe("isPositiveInteger") {
            context("positive number") {
                it("should be true") {
                    expect("123".isPositiveInteger).to(beTrue())
                }
            }
            context("positive negative number") {
                it("should be false") {
                    expect("-123".isPositiveInteger).to(beFalse())
                }
            }
            context("non number") {
                it("should be false") {
                    expect("joeschmoe".isPositiveInteger).to(beFalse())
                }
            }
            context("very large number") {
                it("should be true") {
                    expect("4294967296".isPositiveInteger).to(beTrue())
                }
            }
        }
        describe("trim") {
            context("string with leading and trailing white space") {
                it("should be trimmed") {
                    expect("  \t\t  Let's trim all the whitespace  \n \t  \n  ".trim()).to(equal("Let's trim all the whitespace"))
                }
            }
        }
        describe("toEncodedUrl") {
            context("url encoding failed") {
                it("should return nil") {
                    expect("".toEncodedUrl).to(beNil())
                }
            }
            context("url encoded successfully") {
                it("should return a valid url") {
                    expect("https://soundcloud.com/search?q=Arise, my soul, arise!".toEncodedUrl).toNot(beNil())
                }
            }
        }
    }
}
