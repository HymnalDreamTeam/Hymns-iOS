import Foundation

public class StringUtil {

    /// Returns the Levenshtein Distance between two strings, as long as both strings are non-empty. If either is empty, then return -1.
    static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        if s1.isEmpty || s2.isEmpty {
            return -1
        }

        let m = s1.count
        let n = s2.count
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

        for i in 0...m {
            for j in 0...n {
                if i == 0 {
                    dp[i][j] = j
                } else if j == 0 {
                    dp[i][j] = i
                } else {
                    let cost = s1[s1.index(s1.startIndex, offsetBy: i - 1)] == s2[s2.index(s2.startIndex, offsetBy: j - 1)] ? 0 : 1
                    dp[i][j] = min(dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost)
                }
            }
        }

        return dp[m][n]
    }
}
