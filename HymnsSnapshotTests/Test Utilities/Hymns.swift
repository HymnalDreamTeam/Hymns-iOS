import Foundation
@testable import Hymns

// swiftlint:disable force_try identifier_name
class Hymns {}

let hymn1151_hymn = getHymnFromJson(fileName: "classic_1151")
let hymn1334_hymn = getHymnFromJson(fileName: "classic_1334")
let hymn40_hymn = getHymnFromJson(fileName: "classic_40")

func getHymnFromJson(fileName: String) -> HymnEntity {
//    let decoder = JSONDecoder()
//    decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//    let jsonPath = Bundle(for: Hymns.self).path(forResource: fileName, ofType: "json")!
//    let jsonString = try! String(contentsOfFile: jsonPath)
//    let jsonData = jsonString.data(using: .utf8)!
//    return try! decoder.decode(Hymn.self, from: jsonData)
    return HymnEntityBuilder().build()
}
