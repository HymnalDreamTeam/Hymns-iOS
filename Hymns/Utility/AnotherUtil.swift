import FirebaseCrashlytics
import Foundation
import Network
import Resolver
import StoreKit
import SystemConfiguration

protocol AnotherUtil {

    func rtrue() -> Bool
}

class AnotherUtilImpl: AnotherUtil {
    func rtrue() -> Bool {
        true
    }
}
