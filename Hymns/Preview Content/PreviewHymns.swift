import Foundation
import Resolver

// swiftlint:disable all

#if DEBUG
let decoder: JSONDecoder = Resolver.resolve()
let classic40_preview = getHymnFromJson(fileName: "classic40")
let classic1151_preview = getHymnFromJson(fileName: "classic1151")
let classic1334_preview = getHymnFromJson(fileName: "classic1334")
let chineseSupplement216_preview = getHymnFromJson(fileName: "chineseSupplement216")

func getHymnFromJson(fileName: String) -> HymnEntity {
//    let jsonPath = Bundle.main.path(forResource: fileName, ofType: "json")!
//    let jsonString = try! String(contentsOfFile: jsonPath)
//    let jsonData = jsonString.data(using: .utf8)!
//    return try! decoder.decode(Hymn.self, from: jsonData)
    return HymnEntityBuilder(hymnIdentifier: HymnIdentifier(hymnType: .cebuano, hymnNumber: "booyah")).build()

}
#endif
