import Foundation
import XCTest

/**
 * Extension of XCTestCase to provide common utility methods used by all tests.
 */
extension XCTestCase {
    class func createValidResponse(for url: URL) -> HTTPURLResponse {
        return HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
}
