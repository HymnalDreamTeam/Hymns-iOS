import Foundation

protocol AppError: Error {
    var errorDescription: String { get }
}

struct DatabasePathError: AppError {
    let errorDescription: String
}

struct DatabaseFileNotFoundError: AppError {
    let errorDescription: String
}

struct DatabaseInitializationError: AppError {
    let errorDescription: String
}

struct EmptySearchInputError: AppError {
    let errorDescription: String
}

struct SongSaveError: AppError {
    let errorDescription: String
}

struct TransliterationMisMatchError: AppError {
    let errorDescription: String
}

struct SongLinkParsingError: AppError {
    let errorDescription: String
}

struct SongResultParsingError: AppError {
    let errorDescription: String
}

struct MalformedScriptureReference: AppError {
    let errorDescription: String
}

struct AudioInitializationError: AppError {
    let errorDescription: String
}

struct FavoriteDeletionError: AppError {
    let errorDescription: String
}

struct MalformedPrivacyPolicyError: AppError {
    let errorDescription: String
}

struct UnidentifiedCoffeeDonationId: AppError {
    let errorDescription: String
}

struct UnrecognizedCoffeeSelection: AppError {
    let errorDescription: String
}

struct DatabaseDeletionError: AppError {
    let errorDescription: String
}

struct SongbaseMigrationError: AppError {
    let errorDescription: String
}

struct FavoritesMigrationError: AppError {
    let errorDescription: String
}

struct TagMigrationError: AppError {
    let errorDescription: String
}

struct HistoryMigrationError: AppError {
    let errorDescription: String
}
