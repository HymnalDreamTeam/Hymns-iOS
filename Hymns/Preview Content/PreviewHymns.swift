import Foundation
import Resolver

// swiftlint:disable all

let decoder: JSONDecoder = Resolver.resolve()
let classic1151_preview = getHymnFromJson(fileName: "classic1151")
let classic1334_preview = getHymnFromJson(fileName: "classic1334")

func getHymnFromJson(fileName: String) -> Hymn {
    let jsonPath = Bundle.main.path(forResource: fileName, ofType: "json")!
    let jsonString = try! String(contentsOfFile: jsonPath)
    let jsonData = jsonString.data(using: .utf8)!
    return try! decoder.decode(Hymn.self, from: jsonData)
}
