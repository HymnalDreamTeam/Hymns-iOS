import FirebaseAnalytics
import FirebaseCrashlytics
import Foundation
import Resolver
import StoreKit
import SwiftUI

class DonationViewModel: ObservableObject {

    static let donationCoffee1Id = "donation_coffee_1"
    static let donationCoffee5Id = "donation_coffee_5"
    static let donationCoffee10Id = "donation_coffee_10"

    @Published var coffeeDonations: [DonationType]
    @Binding var resultBinding: Result<SettingsToastItem, Error>?

    private let donationTypeToDonation: [DonationType: CoffeeDonation]

    init(coffeeDonations: [any CoffeeDonation], resultBinding: Binding<Result<SettingsToastItem, Error>?>) {
        self.donationTypeToDonation = coffeeDonations.compactMap { coffeeDonation -> (donationType: DonationType, coffeeDonation: CoffeeDonation)? in
            guard let donationType = DonationType(rawValue: coffeeDonation.id) else {
                Crashlytics.crashlytics().record(error: NonFatal(localizedDescription: "Found unidentified coffee donation id \(coffeeDonation.id)"))
                return nil
            }
            return (donationType: donationType, coffeeDonation: coffeeDonation)
        }.reduce(into: [DonationType: CoffeeDonation](), { partialResult, tuple in
            partialResult[tuple.donationType] = tuple.coffeeDonation
        })
        self.coffeeDonations = donationTypeToDonation.map({ $0.key }).sorted(by: { donation1, donation2 in
            donation2.rank > donation1.rank
        })
        self._resultBinding = resultBinding
    }

    @MainActor
    func initiatePurchase(donationType: DonationType) async {
        guard let coffeeDonation = donationTypeToDonation[donationType] else {
            Crashlytics.crashlytics().record(error: NonFatal(localizedDescription: "Unrecognized coffee donation selection made: \(donationType). This should never ever happen."))
            self.resultBinding = .success(.donate(.other))
            return
        }

        do {
            let purchaseResult = try await coffeeDonation.purchase(options: [])
            let params: [String: Any] = [
                "product": coffeeDonation,
                "result": purchaseResult]
            Analytics.logEvent(AnalyticsEventPurchase, parameters: params)
            switch purchaseResult {
            case .success:
                self.resultBinding = .success(.donate(.success))
            case .userCancelled:
                self.resultBinding = .success(.donate(.cancelled))
            default:
                self.resultBinding = .success(.donate(.other))
            }
        } catch {
            Crashlytics.crashlytics().record(error: error)
            self.resultBinding = .failure(error)
        }
    }
}

enum DonationType: String {
    case donationCoffee1 = "donation_coffee_1"
    case donationCoffee5 = "donation_coffee_5"
    case donationCoffee10 = "donation_coffee_10"

    /**
     * Used for sorting.
     */
    var rank: Int {
        switch self {
        case .donationCoffee1:
            return 1
        case .donationCoffee5:
            return 5
        case .donationCoffee10:
            return 10
        }
    }

    var displayText: String {
        switch self {
        case .donationCoffee1:
            return NSLocalizedString("Buy us **1 coffee** to wake us up!", comment: "Donate one coffee message.")
        case .donationCoffee5:
            return NSLocalizedString("Buy us **5 coffees** to keep us working the entire day!", comment: "Donate five coffees message.")
        case .donationCoffee10:
            return NSLocalizedString("Buy us **10 coffees** to keep us working all night long!", comment: "Donate ten coffees message.")
        }
    }
}

public enum DonationResult {
    case success
    case cancelled
    case other
}