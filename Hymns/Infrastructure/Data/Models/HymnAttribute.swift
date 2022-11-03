import Foundation

enum HymnAttribute {
    case category(category: String, hymnType: HymnType? = nil)
    case subcategory(category: String? = nil, subcategory: String, hymnType: HymnType? = nil)
    case author(_ author: String)
    case composer(_ composer: String)
    case key(_ key: String)
    case time(_ time: String)
    case meter(_ meter: String)
    case scriptures(_ scriptures: String)
    case hymnType(_ hymnType: HymnType)
    case hymnCode(_ hymnCode: String)
    case tag(tag: UiTag)

    var title: String {
        switch self {
        case .category(let category, _):
            return category
        case .subcategory(_, let subcategory, _):
            return subcategory
        case .author(let author):
            return String(format: NSLocalizedString("Songs written by \"%@\"", comment: "Title of a list of songs with a particular author."), author)
        case .composer(let composer):
            return String(format: NSLocalizedString("Songs composed by \"%@\"", comment: "Title of a list of songs with a particular composer."), composer)
        case .key(let key):
            return String(format: NSLocalizedString("Songs with the key \"%@\"", comment: "Title of a list of songs with a particular key."), key)
        case .time(let time):
            return String(format: NSLocalizedString("Songs with the time \"%@\"", comment: "Title of a list of songs with a particular time."), time)
        case .meter(let meter):
            return String(format: NSLocalizedString("Songs with the meter \"%@\"", comment: "Title of a list of songs with a particular meter."), meter)
        case .scriptures(let scriptures):
            return scriptures
        case .hymnCode(let hymnCode):
            return hymnCode
        case .hymnType(let hymnType):
            return hymnType.displayTitle
        case .tag(let tag):
            return String(format: NSLocalizedString("Songs tagged with \"%@\"", comment: "Title of a list of songs tagged with a particular tag."), tag.title)
        }
    }
}

extension HymnAttribute: Equatable {
    // swiftlint:disable:next cyclomatic_complexity
    static func == (lhs: HymnAttribute, rhs: HymnAttribute) -> Bool {
        switch (lhs, rhs) {
        case (let .category(lhsCategory, lhsSubcategory), let .category(rhsCategory, rhsSubcategory)):
            return lhsCategory == rhsCategory && lhsSubcategory == rhsSubcategory
        case (let .subcategory(lhsCategory, lhsSubcategory, lhsHymnType), let .subcategory(rhsCategory, rhsSubcategory, rhsHymnType)):
            return lhsCategory == rhsCategory && lhsSubcategory == rhsSubcategory && lhsHymnType == rhsHymnType
        case (let .author(lhsAuthor), let .author(rhsAuthor)):
            return lhsAuthor == rhsAuthor
        case (let .composer(lhsComposer), let .composer(rhsComposer)):
            return lhsComposer == rhsComposer
        case (let .key(lhsKey), let .key(rhsKey)):
            return lhsKey == rhsKey
        case (let .time(lhsTime), let .time(rhsTime)):
            return lhsTime == rhsTime
        case (let .meter(lhsMeter), let .meter(rhsMeter)):
            return lhsMeter == rhsMeter
        case (let .scriptures(lhsScriptures), let .scriptures(rhsScriptures)):
            return lhsScriptures == rhsScriptures
        case (let .hymnCode(lhsHymnCode), let .hymnCode(rhsHymnCode)):
            return lhsHymnCode == rhsHymnCode
        case (let .hymnType(lhsHymnType), let .hymnType(rhsHymnType)):
            return lhsHymnType == rhsHymnType
        case (let .tag(lhsTag), let .tag(rhsTag)):
            return lhsTag == rhsTag
        default:
            return false
        }
    }
}
