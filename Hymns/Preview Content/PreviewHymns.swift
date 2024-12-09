import Foundation
import Resolver

#if DEBUG

// swiftlint:disable all
let decoder: JSONDecoder = Resolver.resolve()
let classic40_preview = getHymnEntityFromJson(fileName: "classic40")
let classic1151_preview = getHymnEntityFromJson(fileName: "classic1151")
let classic1334_preview = getHymnEntityFromJson(fileName: "classic1334")
let chineseSupplement216_preview = getHymnEntityFromJson(fileName: "chineseSupplement216")

func getHymnEntityFromJson(fileName: String, converter: Converter = Resolver.resolve()) -> HymnEntity {
    return try! converter.toHymnEntity(hymn: getHymnFromJson(fileName: fileName))
}

private func getHymnFromJson(fileName: String) -> Hymn {
    let jsonPath = Bundle.main.path(forResource: fileName, ofType: "json")!
    let jsonString = try! String(contentsOfFile: jsonPath)
    let jsonData = jsonString.data(using: .utf8)!
    return try! decoder.decode(Hymn.self, from: jsonData)
}

// swiftlint:enable all
#endif
