import Foundation

/**
 * Raw value needs to be an Int to preserve the ordering of the books.
 */
enum Book: Int {
    case genesis
    case exodus
    case leviticus
    case numbers
    case deuteronomy
    case joshua
    case judges
    case ruth
    case firstSamuel
    case secondSamuel
    case firstKings
    case secondKings
    case firstChronicles
    case secondChronicles
    case ezra
    case nehemiah
    case esther
    case job
    case psalms
    case proverbs
    case ecclesiastes
    case songOfSongs
    case isaiah
    case jeremiah
    case lamentations
    case ezekiel
    case daniel
    case hosea
    case joel
    case amos
    case obadiah
    case jonah
    case micah
    case nahum
    case habakkuk
    case zephaniah
    case haggai
    case zechariah
    case malachi
    case matthew
    case mark
    case luke
    case john
    case acts
    case romans
    case firstCorinthians
    case secondCorinthians
    case galatians
    case ephesians
    case philippians
    case colossians
    case firstThessalonians
    case secondThessalonians
    case firstTimothy
    case secondTimothy
    case titus
    case philemon
    case hebrews
    case james
    case firstPeter
    case secondPeter
    case firstJohn
    case secondJohn
    case thirdJohn
    case jude
    case revelation
}

extension Book {

    var bookName: String {
        switch self {
        case .genesis: return NSLocalizedString("Genesis", comment: "The Book of Genesis.")
        case .exodus: return NSLocalizedString("Exodus", comment: "The Book of Exodus.")
        case .leviticus: return NSLocalizedString("Leviticus", comment: "The Book of Leviticus.")
        case .numbers: return NSLocalizedString("Numbers", comment: "The Book of Numbers.")
        case .deuteronomy: return NSLocalizedString("Deuteronomy", comment: "The Book of Deuteronomy.")
        case .joshua: return NSLocalizedString("Joshua", comment: "The Book of Joshua.")
        case .judges: return NSLocalizedString("Judges", comment: "The Book of Judges.")
        case .ruth: return NSLocalizedString("Ruth", comment: "The Book of Ruth.")
        case .firstSamuel: return NSLocalizedString("1 Samuel", comment: "The Book of 1 Samuel.")
        case .secondSamuel: return NSLocalizedString("2 Samuel", comment: "The Book of 2 Samuel.")
        case .firstKings: return NSLocalizedString("1 Kings", comment: "The Book of 1 Kings.")
        case .secondKings: return NSLocalizedString("2 Kings", comment: "The Book of 2 Kings.")
        case .firstChronicles: return NSLocalizedString("1 Chronicles", comment: "The Book of 1 Chronicles.")
        case .secondChronicles: return NSLocalizedString("2 Chronicles", comment: "The Book of 2 Chronicles.")
        case .ezra: return NSLocalizedString("Ezra", comment: "The Book of Ezra.")
        case .nehemiah: return NSLocalizedString("Nehemiah", comment: "The Book of Nehemiah.")
        case .esther: return NSLocalizedString("Esther", comment: "The Book of Esther.")
        case .job: return NSLocalizedString("Job", comment: "The Book of Job.")
        case .psalms: return NSLocalizedString("Psalms", comment: "The Book of Psalms.")
        case .proverbs: return NSLocalizedString("Proverbs", comment: "The Book of Proverbs.")
        case .ecclesiastes: return NSLocalizedString("Ecclesiastes", comment: "The Book of Ecclesiastes.")
        case .songOfSongs: return NSLocalizedString("Song of Songs", comment: "The Book of Song of Songs.")
        case .isaiah: return NSLocalizedString("Isaiah", comment: "The Book of Isaiah.")
        case .jeremiah: return NSLocalizedString("Jeremiah", comment: "The Book of Jeremiah.")
        case .lamentations: return NSLocalizedString("Lamentations", comment: "The Book of Lamentations.")
        case .ezekiel: return NSLocalizedString("Ezekiel", comment: "The Book of Ezekiel.")
        case .daniel: return NSLocalizedString("Daniel", comment: "The Book of Daniel.")
        case .hosea: return NSLocalizedString("Hosea", comment: "The Book of Hosea.")
        case .joel: return NSLocalizedString("Joel", comment: "The Book of Joel.")
        case .amos: return NSLocalizedString("Amos", comment: "The Book of Amos.")
        case .obadiah: return NSLocalizedString("Obadiah", comment: "The Book of Obadiah.")
        case .jonah: return NSLocalizedString("Jonah", comment: "The Book of Jonah.")
        case .micah: return NSLocalizedString("Micah", comment: "The Book of Micah.")
        case .nahum: return NSLocalizedString("Nahum", comment: "The Book of Nahum.")
        case .habakkuk: return NSLocalizedString("Habakkuk", comment: "The Book of Habakkuk.")
        case .zephaniah: return NSLocalizedString("Zephaniah", comment: "The Book of Zephaniah.")
        case .haggai: return NSLocalizedString("Haggai", comment: "The Book of Haggai.")
        case .zechariah: return NSLocalizedString("Zechariah", comment: "The Book of Zechariah.")
        case .malachi: return NSLocalizedString("Malachi", comment: "The Book of Malachi.")
        case .matthew: return NSLocalizedString("Matthew", comment: "The Book of Matthew.")
        case .mark: return NSLocalizedString("Mark", comment: "The Book of Mark.")
        case .luke: return NSLocalizedString("Luke", comment: "The Book of Luke.")
        case .john: return NSLocalizedString("John", comment: "The Book of John.")
        case .acts: return NSLocalizedString("Acts", comment: "The Book of Acts.")
        case .romans: return NSLocalizedString("Romans", comment: "The Book of Romans.")
        case .firstCorinthians: return NSLocalizedString("1 Corinthians", comment: "The Book of 1 Corinthians.")
        case .secondCorinthians: return NSLocalizedString("2 Corinthians", comment: "The Book of 2 Corinthians.")
        case .galatians: return NSLocalizedString("Galatians", comment: "The Book of Galatians.")
        case .ephesians: return NSLocalizedString("Ephesians", comment: "The Book of Ephesians.")
        case .philippians: return NSLocalizedString("Philippians", comment: "The Book of Philippians.")
        case .colossians: return NSLocalizedString("Colossians", comment: "The Book of Colossians.")
        case .firstThessalonians: return NSLocalizedString("1 Thessalonians", comment: "The Book of 1 Thessalonians.")
        case .secondThessalonians: return NSLocalizedString("2 Thessalonians", comment: "The Book of 2 Thessalonians.")
        case .firstTimothy: return NSLocalizedString("1 Timothy", comment: "The Book of 1 Timothy.")
        case .secondTimothy: return NSLocalizedString("2 Timothy", comment: "The Book of 2 Timothy.")
        case .titus: return NSLocalizedString("Titus", comment: "The Book of Titus.")
        case .philemon: return NSLocalizedString("Philemon", comment: "The Book of Philemon.")
        case .hebrews: return NSLocalizedString("Hebrews", comment: "The Book of Hebrews.")
        case .james: return NSLocalizedString("James", comment: "The Book of James.")
        case .firstPeter: return NSLocalizedString("1 Peter", comment: "The Book of 1 Peter.")
        case .secondPeter: return NSLocalizedString("2 Peter", comment: "The Book of 2 Peter.")
        case .firstJohn: return NSLocalizedString("1 John", comment: "The Book of 1 John.")
        case .secondJohn: return NSLocalizedString("2 John", comment: "The Book of 2 John.")
        case .thirdJohn: return NSLocalizedString("3 John", comment: "The Book of 3 John.")
        case .jude: return NSLocalizedString("Jude", comment: "The Book of Jude.")
        case .revelation: return NSLocalizedString("Revelation", comment: "The Book of Revelation.")
        }
    }

    // Can't reduce cyclomatic complexity here since the Bible has 67 books.
    // swiftlint:disable cyclomatic_complexity
    static func from(bookName: String) -> Book? {
        switch bookName {
        case "Genesis": return .genesis
        case "Exodus": return .exodus
        case "Leviticus": return .leviticus
        case "Numbers": return .numbers
        case "Deuteronomy": return .deuteronomy
        case "Joshua": return .joshua
        case "Judges": return .judges
        case "Ruth": return .ruth
        case "1 Samuel": return .firstSamuel
        case "2 Samuel": return .secondSamuel
        case "1 Kings": return .firstKings
        case "2 Kings": return .secondKings
        case "1 Chronicles": return .firstChronicles
        case "2 Chronicles": return .secondChronicles
        case "Ezra": return .ezra
        case "Nehemiah": return .nehemiah
        case "Esther": return .esther
        case "Job": return .job
        case "Psalms": return .psalms
        case "Proverbs": return .proverbs
        case "Ecclesiastes": return .ecclesiastes
        case "Song of Songs": return .songOfSongs
        case "Isaiah": return .isaiah
        case "Jeremiah": return .jeremiah
        case "Lamentations": return .lamentations
        case "Ezekiel": return .ezekiel
        case "Daniel": return .daniel
        case "Hosea": return .hosea
        case "Joel": return .joel
        case "Amos": return .amos
        case "Obadiah": return .obadiah
        case "Jonah": return .jonah
        case "Micah": return .micah
        case "Nahum": return .nahum
        case "Habakkuk": return .habakkuk
        case "Zephaniah": return .zephaniah
        case "Haggai": return .haggai
        case "Zechariah": return .zechariah
        case "Malachi": return .malachi
        case "Matthew": return .matthew
        case "Mark": return .mark
        case "Luke": return .luke
        case "John": return .john
        case "Acts": return .acts
        case "Romans": return .romans
        case "1 Corinthians": return .firstCorinthians
        case "2 Corinthians": return .secondCorinthians
        case "Galatians": return .galatians
        case "Ephesians": return .ephesians
        case "Philippians": return .philippians
        case "Colossians": return .colossians
        case "1 Thessalonians": return .firstThessalonians
        case "2 Thessalonians": return .secondThessalonians
        case "1 Timothy": return .firstTimothy
        case "2 Timothy": return .secondTimothy
        case "Titus": return .titus
        case "Philemon": return .philemon
        case "Hebrews": return .hebrews
        case "James": return .james
        case "1 Peter": return .firstPeter
        case "2 Peter": return .secondPeter
        case "1 John": return .firstJohn
        case "2 John": return .secondJohn
        case "3 John": return .thirdJohn
        case "Jude": return .jude
        case "Revelation": return .revelation
        default: return nil
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
