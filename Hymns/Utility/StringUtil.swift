import Foundation

public class StringUtil {

    /// Returns the Levenshtein Distance between two strings, as long as both strings are non-empty. If either is empty, then return -1.
    static func levenshteinDistance(_ str1: String, _ str2: String) -> Int {
        if str1.isEmpty || str2.isEmpty {
            return -1
        }

        let str1Count = str1.count
        let str2Count = str2.count
        var dist = Array(repeating: Array(repeating: 0, count: str2Count + 1), count: str1Count + 1)

        for str1Index in 0...str1Count {
            for str2Index in 0...str2Count {
                if str1Index == 0 {
                    dist[str1Index][str2Index] = str2Index
                } else if str2Index == 0 {
                    dist[str1Index][str2Index] = str1Index
                } else {
                    let cost = str1[str1.index(str1.startIndex, offsetBy: str1Index - 1)] == str2[str2.index(str2.startIndex, offsetBy: str2Index - 1)] ? 0 : 1
                    dist[str1Index][str2Index] = min(dist[str1Index - 1][str2Index] + 1, dist[str1Index][str2Index - 1] + 1, dist[str1Index - 1][str2Index - 1] + cost)
                }
            }
        }
        return dist[str1Count][str2Count]
    }
}
