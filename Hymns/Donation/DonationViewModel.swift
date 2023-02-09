import FirebaseAnalytics
import FirebaseCrashlytics
import Foundation
import Resolver
import StoreKit
import SwiftUI

// TODO unit test here: https://www.appcoda.com/storekit-testing/

class DonationViewModel: ObservableObject {

    @Published var coffeeDonations: [Product]?
    @Binding var result: Result<SettingsToastItem, Error>?

    init(result: Binding<Result<SettingsToastItem, Error>?>) {
        self.coffeeDonations = [Product]()
        self._result = result
    }

    @MainActor
    func fetchProduct() async {
        do {
            coffeeDonations = try await Product.products(for: ["donation_coffee_1", "donation_coffee_5"])
        } catch {
            Crashlytics.crashlytics().record(error: error)
            coffeeDonations = [Product]()
        }
    }

    @MainActor
    func initiatePurchase(_ coffeeDonation: Product) async {
        do {
            let purchaseResult = try await coffeeDonation.purchase()

            let params: [String: Any] = [
                "product": coffeeDonation,
                "result": purchaseResult]
            Analytics.logEvent(AnalyticsEventPurchase, parameters: params)

            switch purchaseResult {
            case .success:
                self.result = .success(.donate(.success))
            case .userCancelled:
                self.result = .success(.donate(.cancelled))
            default:
                self.result = .success(.donate(.other))
            }
        } catch {
            Crashlytics.crashlytics().record(error: error)
            self.result = .failure(error)
        }
    }
}

public enum DonationResult {
    case success
    case cancelled
    case other
}
