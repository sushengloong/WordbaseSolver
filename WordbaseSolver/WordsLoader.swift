import UIKit

class WordsLoader: NSObject {
    func loadFromFile() -> [String] {
        if let path = Bundle.main.path(forResource: "words_en", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let words = data.components(separatedBy: .newlines)
                print("Read \(words.count) words from text file")
                return words
            } catch {
                print(error)
            }
        }
        return [String]()
    }
}
