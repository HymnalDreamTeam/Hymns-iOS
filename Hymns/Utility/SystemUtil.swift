import FirebaseCrashlytics
import Foundation
import Network
import Resolver
import StoreKit
import SystemConfiguration

protocol SystemUtil {

    var donationProducts: [any CoffeeDonation] { get }

    func isNetworkAvailable() -> Bool

    /**
     * We define a small screen to be a screen with width less than or equal to 350 pixels.
     */
    func isSmallScreen() -> Bool

    func loadDonationProducts() async
}

class SystemUtilImpl: SystemUtil {

    var donationProducts: [any CoffeeDonation] = []

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

    func loadDonationProducts() async {
        guard isNetworkAvailable() else {
            donationProducts = []
            return
        }
        do {
            donationProducts = try await Product.products(for: [DonationViewModel.donationCoffee1Id,
                                                                DonationViewModel.donationCoffee5Id,
                                                                DonationViewModel.donationCoffee10Id])
        } catch {
            Crashlytics.crashlytics().record(error: error)
            donationProducts = []
        }
    }
}
