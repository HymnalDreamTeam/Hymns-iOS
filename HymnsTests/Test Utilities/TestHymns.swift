import Foundation
import Resolver
@testable import Hymns

// swiftlint:disable all
class TestHymns{}

let cebuano123 = HymnIdentifier(hymnType: .cebuano, hymnNumber: "123")
let cebuano123QueryParams = HymnIdentifier(hymnType: .cebuano, hymnNumber: "123", queryParams: ["gb": "1"])
let children24 = HymnIdentifier(hymnType: .children, hymnNumber: "24")
let classic1151 = HymnIdentifier(hymnType: .classic, hymnNumber: "1151")
let newSong145 = HymnIdentifier(hymnType: .newSong, hymnNumber: "145")
let newSong500 = HymnIdentifier(hymnType: .newSong, hymnNumber: "500")
let classic1109 = HymnIdentifier(hymnType: .classic, hymnNumber: "1109")
let classic500 = HymnIdentifier(hymnType: .classic, hymnNumber: "500")
let classic501 = HymnIdentifier(hymnType: .classic, hymnNumber: "501")
let songbase1 = HymnIdentifier(hymnType: .songbase, hymnNumber: "1")

let decoder: JSONDecoder = Resolver.resolve()
let children_24_json = getJsonString(for: "children_24")
let children_24_hymn = getHymnFromJson(for: "children_24")
let children_24_hymn_entity = HymnEntityBuilder(hymnIdentifier: children24).title(Optional("Hymn: He Didn’t Stay Home")).lyricsJson(Optional("[{\"verse_type\":\"verse\",\"verse_content\":[\"He didn’t stay home;\",\"He went and visited people.\",\"He didn’t stay home;\",\"Jesus taught disciples.\",\"Fed the following crowd outdoors;\",\"Made them glad forevermore;\",\"Serving’s what His life was for;\",\"He didn’t stay home. SO!!!!!\"]},{\"verse_type\":\"verse\",\"verse_content\":[\"Don’t stay home! (go, go!)\",\"Go and visit people!\",\"Don’t stay home! (go, go!)\",\"Go and teach disciples. (GO!)\",\"Fix some food, go out the door;\",\"Make them glad forevermore;\",\"Serving is what life is for,\",\"So DON’T STAY HOME!!\"]},{\"verse_type\":\"other\",\"verse_content\":[\"\\n\",\"© 2012 Bible StorySongs, Inc. Used by permission.\",\"Visit BibleStorySongs.com to order CD’s & Sheet Music.\",\"\\n\"]}]")).category(Optional("Preaching of the Gospel")).subcategory(Optional("Go Ye!")).author(Optional("P. K.C. R. W.")).composer(Optional("Traditional (1908)")).key(Optional("E Major")).time(Optional("4/4")).meter(nil).scriptures(nil).hymnCode(Optional("5332153322172")).musicJson(Optional("{\"name\":\"Music\",\"data\":[{\"value\":\"mp3\",\"path\":\"\\/en\\/hymn\\/c\\/24\\/f=mp3\"},{\"value\":\"MIDI\",\"path\":\"\\/en\\/hymn\\/c\\/24\\/f=mid\"},{\"value\":\"Tune (MIDI)\",\"path\":\"\\/en\\/hymn\\/c\\/24\\/f=tune\"}]}")).svgSheetJson(Optional("{\"name\":\"svg\",\"data\":[{\"value\":\"Piano\",\"path\":\"https:\\/\\/www.hymnal.net\\/Hymns\\/Children\\/svg\\/child0024_p.svg\"},{\"value\":\"Guitar\",\"path\":\"https:\\/\\/www.hymnal.net\\/Hymns\\/Children\\/svg\\/child0024_g.svg\"}]}")).pdfSheetJson(Optional("{\"name\":\"Lead Sheet\",\"data\":[{\"value\":\"Piano\",\"path\":\"\\/en\\/hymn\\/c\\/24\\/f=ppdf\"},{\"value\":\"Guitar\",\"path\":\"\\/en\\/hymn\\/c\\/24\\/f=pdf\"},{\"value\":\"Text\",\"path\":\"\\/en\\/hymn\\/c\\/24\\/f=gtpdf\"}]}")).languagesJson(nil).relevantJson(nil).build()

let classic_1151_json = getJsonString(for: "classic_1151")
let classic_1151_hymn = getHymnFromJson(for: "classic_1151")
let classic_1151_hymn_entity = HymnEntityBuilder(hymnIdentifier: classic1151).title(Optional("Hymn: Drink! A river pure and clear that's flowing from the throne")).lyricsJson(Optional("[{\"verse_content\": [\"Drink! A river pure and clear that's flowing from the throne;\", \"Eat! The tree of life with fruits abundant, richly grown;\", \"Look! No need of lamp nor sun nor moon to keep it bright, for\", \"Here there is no night!\"], \"verse_type\": \"verse\"}, {\"verse_content\": [\"Do come, oh, do come,\", \"Says Spirit and the Bride:\", \"Do come, oh, do come,\", \"Let him that heareth, cry.\", \"Do come, oh, do come,\", \"Let him who thirsts and will\", \"Take freely the water of life!\"], \"verse_type\": \"chorus\"}, {\"verse_content\": [\"Christ, our river, Christ, our water, springing from within;\", \"Christ, our tree, and Christ, the fruits, to be enjoyed therein,\", \"Christ, our day, and Christ, our light, and Christ, our morningstar:\", \"Christ, our everything!\"], \"verse_type\": \"verse\"}, {\"verse_content\": [\"We are washing all our robes the tree of life to eat;\", \"\"O Lord, Amen, Hallelujah!\"—Jesus is so sweet!\", \"We our spirits exercise, and thus experience Christ.\", \"What a Christ have we!\"], \"verse_type\": \"verse\"}, {\"verse_content\": [\"Now we have a home so bright that outshines the sun,\", \"Where the brothers all unite and truly are one.\", \"Jesus gets us all together, Him we now display\", \"In the local church.\"], \"verse_type\": \"verse\"}]")).build()

let classic_1109_json = getJsonString(for: "classic_1109")
let classic_1109_hymn = getHymnFromJson(for: "classic_1109")
let classic_1109_hymn_entity = HymnEntityBuilder(hymnIdentifier: classic1109).title(Optional("Hymn: Take, drink this cup, His blood")).lyricsJson(Optional("[{\"verse_content\": [\"Take, drink this cup, His blood,\", \"Redemption of our God.\", \"The peace which Christ has made,\", \"Is in this cup displayed.\", \"We fellowship now with the Son:\", \"On Calvary the work was done:\", \"The way is clear, now all can come!\"], \"verse_type\": \"verse\"}, {\"verse_content\": [\"Take, drink this cup, each one,\", \"His death show till He come.\", \"Eat, drink, display this feast:\", \"God in the Lamb released!\", \"Around the table, sup and dine;\", \"We eat the bread and drink the wine.\", \"All blessing in this cup we find.\"], \"verse_type\": \"verse\"}, {\"verse_content\": [\"No blood of cow or goat\", \"Could give us any hope.\", \"Our sins would all remain\", \"Still year by year the same.\", \"A God-man, sinless, He must find\", \"No other offering of His kind,\", \"A spotless lamb for all mankind.\"], \"verse_type\": \"verse\"}, {\"verse_content\": [\"Come! Now enjoy His blood.\", \"What access this to God!\", \"Here wondrous cleansing power\", \"Flows to us, hour by hour.\", \"One sacrifice for all was made,\", \"And peace our conscience does pervade.\", \"Redemption's price is fully paid!\"], \"verse_type\": \"verse\"}, {\"verse_content\": [\"Redeemer! Savior! King!\", \"Of Thy dear blood we sing,\", \"For in it now we see\", \"Thy mercy, boundless, free.\", \"This cup, our portion blessed of God,\", \"Is of the cov'nant in Thy blood—\", \"Dear, precious, precious, priceless blood!\"], \"verse_type\": \"verse\"}]")).build()

let search_drink_json = getJsonString(for: "search_drink")
let search_drink_song_result_page = getSongResultPageFromJson(for: "search_drink")
let search_drink_page_3_json = getJsonString(for: "search_drink_page_3")
let search_drink_page_3_song_result_page = getSongResultPageFromJson(for: "search_drink_page_3")
let search_drink_page_10_json = getJsonString(for: "search_drink_page_10")
let search_drink_page_10_song_result_page = getSongResultPageFromJson(for: "search_drink_page_10")

func getJsonString(for fileName: String) -> String {
    let jsonPath = Bundle(for: TestHymns.self).path(forResource: fileName, ofType: "json")!
    return try! String(contentsOfFile: jsonPath)
}

func getHymnFromJson(for fileName: String) -> Hymn {
    return getModelFromJson(for: fileName, as: Hymn.self)
}

func getSongResultPageFromJson(for fileName: String) -> SongResultsPage {
    return getModelFromJson(for: fileName, as: SongResultsPage.self)
}

func getModelFromJson<ModelType: Decodable>(for fileName: String, as modelType: ModelType.Type) -> ModelType {
    let jsonString = getJsonString(for: fileName)
    let jsonData = jsonString.data(using: .utf8)!
    return try! decoder.decode(ModelType.self, from: jsonData)
}
