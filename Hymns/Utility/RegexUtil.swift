import Foundation

public class RegexUtil {

    /**
     * Regex format to extract the hymn type and hymn number from a search query to perform a specialized search query for that hymn type
     *
     * Examples: <br>
     *     cebuano 555 --> cebuano, 555 <br>
     *     new song 3 --> new song, 555 <br>
     *     ns 3 --> ns, 3 <br>
     */
    static let searchTextPattern = "(\\D+)\\s*(\\d+)"

    /**
     * Regex format to extract information out of a hymn path.<br>
     * (\w+) --> matches any word character (letter, number, or underscore)<br>
     * ([a-z]?\d+[a-z]?) --> maybe a single letter followed by more than 1 digit followed by 0 or more letters. eg: 13, 13f, c333, 54de<br>
     * (?:/f=(\w+\z)|\z) --> conditional to extract the media type if the url contains a media type. eg: ns/17 or ns/17/f=(pdf)<br>
     *   ?: --> do not extract whatever is matched<br>
     *          http://stackoverflow.com/questions/3378773/can-i-use-an-or-in-regex-without-capturing-whats-enclosed<br>
     *   \w+\z --> any number of word characters at the end of the string<br>
     *   | --> or statement<br>
     *   \z --> the end of the string<br>
     *   <p/>
     *   Examples:<br>
     *       /en/hymn/h/594 --> h, 594, null <br>
     *       /en/hymn/h/13f/f=mp3 --> h, 13f, mp3 <br>
     */
    static let songPathFormat = "(\\w+)/([a-z]?\\d+[a-z]*)(?:/f=(\\w+\\z)|\\z)"

    /**
     * Regex format to extract information out of a scripture reference that doesn't include the verse<br>
     * ([123]?\s?\w+) --> maybe a number 1, 2, or 3, followed by maybe a white space, followed by 1
     *                    or more word characters
     * Examples:<br>
     *     2 Chronicles 15:45
     *     Psalms 45
     *     Psalms
     *     1 John 5:12
     *     3 John 5:12
     *     Jude 1:12
     *     Matthew 17:5-14
     *     Song of Songs 4:12
     *     6:19
     *     80
     *     cf. Psalms 16
     *
     *     See songs:
     *     https://www.hymnal.net/en/hymn/ns/123
     *     https://www.hymnal.net/en/hymn/ns/138
     *     https://www.hymnal.net/en/hymn/h/600
     */
    static let scripturePatternNoVerse = "(?:cf. )?(Song of Songs|(?:[123]\\s)?[a-zA-Z]+)?(?:\\s?(\\d+))?"

    /**
     * Regex format to extract information out of the verse portion of a scripture reference<br>
     */
    static let scripturePatternVerse = "\\A(\\d+(?:-?\\d+)?)\\z"

    /**
     * Regex format to extract the "O/Oh" out of a string.
     * ?i -> case insensitive
     * \b -> word boundary
     */
    static let oOhPattern = "(?i)\\b(oh|o)\\b"
    
    /**
     * Regex format to extract words containing single quotes and apostrophes out of a string.
     * \w -> word character
     */
    static let apostrophePattern = "(\\w+)([’'])(\\w+)"

    /**
     * Regex format to extract the "O/Oh" out of the beginning of a string.
     * \A -> Start of string
     */
    static let dashPattern = "\\A(-*\\s*)"

    static func getHymnType(searchQuery: String) -> HymnType? {
        let regex = NSRegularExpression(searchTextPattern, options: .caseInsensitive)

        if let match = regex.firstMatch(in: searchQuery, options: [], range: NSRange(location: 0, length: searchQuery.utf16.count)) {
            if let hymnTypeRange = Range(match.range(at: 1), in: searchQuery) {
                return HymnType.searchPrefixes[searchQuery[hymnTypeRange].lowercased().trim()]
            }
        }
        return nil
    }

    static func getHymnNumber(searchQuery: String) -> String? {
        let regex = NSRegularExpression(searchTextPattern, options: .caseInsensitive)

        if let match = regex.firstMatch(in: searchQuery, options: [], range: NSRange(location: 0, length: searchQuery.utf16.count)) {
            if let hymnNumberRange = Range(match.range(at: 2), in: searchQuery) {
                let hymnNumber = String(searchQuery[hymnNumberRange]).trim()
                return hymnNumber.isEmpty ? nil : hymnNumber
            }
        }
        return nil
    }

    /**
     * @param path path of the song
     * @return parsed hymn type from path, or null if it's not found
     */
    static func getHymnType(path: String) -> HymnType? {
        let regex = NSRegularExpression(songPathFormat, options: .caseInsensitive)
        let pathWithoutQueryParams = removeQueryParams(path: path)

        if let match = regex.firstMatch(in: pathWithoutQueryParams, options: [], range: NSRange(location: 0, length: pathWithoutQueryParams.utf16.count)),
           let hymnTypeRange = Range(match.range(at: 1), in: pathWithoutQueryParams),
           let hymnType = HymnType.fromAbbreviatedValue(String(pathWithoutQueryParams[hymnTypeRange])) {

            guard let queryParams = getQueryParams(path: path),
                  // swiftlint:disable:next identifier_name
                  let gb = queryParams["gb"] else {
                return hymnType
            }

            if gb == "1" {
                if hymnType == .chinese {
                    return .chineseSimplified
                } else if hymnType == .chineseSupplement {
                    return .chineseSupplementSimplified
                } else {
                    return nil
                }
            }
        }
        return nil
    }

    /**
     * @param path path of the song
     * @return parsed hymn number from path, or null if it's not found
     */
    static func getHymnNumber(path: String) -> String? {
        let regex = NSRegularExpression(songPathFormat, options: .caseInsensitive)
        let pathWithoutQueryParams = removeQueryParams(path: path)

        if let match = regex.firstMatch(in: pathWithoutQueryParams, options: [], range: NSRange(location: 0, length: pathWithoutQueryParams.utf16.count)) {
            if let hymnNumberRange = Range(match.range(at: 2), in: pathWithoutQueryParams) {
                return String(pathWithoutQueryParams[hymnNumberRange])
            }
        }
        return nil
    }

    private static func getQueryParams(path: String) -> [String: String]? {
        guard let url = URL(string: path), let query = url.query else { return nil }
        var queryParams = [String: String]()
        for pair in query.components(separatedBy: "&") {
            let components = pair.components(separatedBy: "=")
            if components.count != 2 {
                continue
            }
            let key = components[0]
            let value = components[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            queryParams[key] = value
        }
        return queryParams.isEmpty ? nil : queryParams
    }

    private static func removeQueryParams(path: String) -> String {
        if let index = path.firstIndex(of: "?") {
            return String(path.prefix(upTo: index))
        } else {
            return path
        }
    }

    static func getBookFromReference(_ reference: String) -> Book? {
        guard let firstReference = reference.components(separatedBy: ":").first else {
            return nil
        }

        let regex = NSRegularExpression(scripturePatternNoVerse, options: .caseInsensitive)
        if let match = regex.firstMatch(in: firstReference, options: [], range: NSRange(location: 0, length: firstReference.utf16.count)) {
            if let hymnTypeRange = Range(match.range(at: 1), in: firstReference) {
                return Book.from(bookName: String(reference[hymnTypeRange]))
            }
        }
        return nil
    }

    static func getChapterFromReference(_ reference: String) -> String? {
        // If the reference is just a single digit, then that's just the verse only, so return
        // a null chapter
        if reference.isPositiveInteger {
            return nil
        }

        guard let firstReference = reference.components(separatedBy: ":").first else {
            return nil
        }
        let regex = NSRegularExpression(scripturePatternNoVerse, options: .caseInsensitive)
        if let match = regex.firstMatch(in: firstReference, options: [], range: NSRange(location: 0, length: firstReference.utf16.count)) {
            if let hymnNumberRange = Range(match.range(at: 2), in: firstReference) {
                return String(reference[hymnNumberRange])
            }
        }
        return nil
    }

    static func getVerseFromReference(_ reference: String) -> String? {
        var secondReference: String
        if reference.contains(":") {
            guard let ref = reference.components(separatedBy: ":").dropFirst().first ?? nil else {
                return nil
            }
            secondReference = ref
        } else {
            secondReference = reference
        }

        let regex = NSRegularExpression(scripturePatternVerse, options: .caseInsensitive)
        if let match = regex.firstMatch(in: secondReference, options: [], range: NSRange(location: 0, length: secondReference.utf16.count)) {
            if let hymnTypeRange = Range(match.range(at: 1), in: secondReference) {
                return String(secondReference[hymnTypeRange])
            }
        }
        return nil
    }

    /// Essentially creates a wildcard match where "O" and "Oh" will match both.
    static func replaceOs(_ str: String) -> String {
        let regex = NSRegularExpression(oOhPattern, options: .caseInsensitive)
        return regex.stringByReplacingMatches(in: str,
                                              range: NSRange(location: 0, length: str.utf16.count),
                                              withTemplate: "(O OR Oh)")
    }

    /// Essentially creates a wildcard match where single quotes and apostrophes will match both.
    static func replaceApostrophes(_ str: String) -> String {
        let regex = NSRegularExpression(apostrophePattern, options: .caseInsensitive)
        return regex.stringByReplacingMatches(in: str,
                                              range: NSRange(location: 0, length: str.utf16.count),
                                              withTemplate: "($1’$3 OR $1'$3)")
    }
}

// https://www.hackingwithswift.com/articles/108/how-to-use-regular-expressions-in-swift
extension NSRegularExpression {
    // Create convenience method to avoid the try! which swiftlint doesn't like
    convenience init(_ pattern: String, options: Options) {
        do {
            try self.init(pattern: pattern, options: options)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }

    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}
