import Foundation
import StoreKit

/**
 * Need to create this type in order to mock out `Product`s in the unit tests.
 * https://mockingbirdswift.com/mocking-external-types
 */
protocol CoffeeDonation {

    /// The unique product identifier.
    var id: String { get }

    /// Processes a purchase for the product.
    /// - Parameter options: A set of options to configure the purchase.
    /// - Returns: The result of the purchase.
    /// - Throws: A `PurchaseError` or `StoreKitError`.
    func purchase(options: Set<Product.PurchaseOption> ) async throws -> PurchaseResultWrapper
}

extension Product: CoffeeDonation {
    func purchase(options: Set<PurchaseOption>) async throws -> PurchaseResultWrapper {
        let purchaseResult: Product.PurchaseResult = try await purchase(options: options)
        switch purchaseResult {
        case .success:
            return .success
        case .userCancelled:
            return .userCancelled
        case .pending:
            return .pending
        @unknown default:
            return .other
        }
    }
}

/**
 * Wrapper around `Product.PurchaseResult` so we can more easily unit test. This is because `PurchaseResult.success` requires a `VerificationResult<Transaction>`, which we cannot
 * initialize in tests because the `Transaction` has no public initializers.
 */
enum PurchaseResultWrapper {
    case success
    case userCancelled
    case pending
    case other
}
