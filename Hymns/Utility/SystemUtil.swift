import Foundation
import Network
import Resolver
import SystemConfiguration

protocol SystemUtil {
    func isNetworkAvailable() -> Bool

    /**
     * We define a small screen to be a screen with width less than or equal to 350 pixels.
     */
    func isSmallScreen() -> Bool
}

class SystemUtilImpl: SystemUtil {

    private let reachability = SCNetworkReachabilityCreateWithName(nil, "www.hymnal.net")

    /// https://designcode.io/swiftui-advanced-handbook-network-connection
    func isNetworkAvailable() -> Bool {
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability!, &flags)

        return flags.contains(.reachable)
    }

    func isSmallScreen() -> Bool {
        return UIScreen.main.bounds.width <= 350
    }
}
