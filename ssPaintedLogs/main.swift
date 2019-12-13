import Foundation
import Commander
import Rainbow

let suffixes = ["SS", "CM", "FU", "SL", "GASP", "Certificate", "ServiceCP", "*** Assertion failure"]
let colors: Dictionary<String, Color> = [
    "SS" : .lightBlue,
    "SL" : .lightBlue,
    "CM" : .green,
    "Certificate" : .green,
    "FU" : .magenta,
    "GASP" : .cyan,
    "ServiceCP" : .cyan,
    "*** Assertion failure": .red
]

extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "<br>").appendToURL(fileURL: fileURL)
    }
    
    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
    
    func embed(wordContainingSubstring word: String, in color: Color) -> String? {
        if let rangeOfWord = self.range(of: word) {
            let startOfWord = rangeOfWord.lowerBound
            let endOfWord = self[rangeOfWord.upperBound...].range(of: " ")?.upperBound ?? endIndex
            let coloredSubstring = String(self[startOfWord...index(before: endOfWord)])
            return self[..<startOfWord]
                + coloredSubstring.applyingColor(color)
                + self[endOfWord...]
        }
        return nil
    }
    
    func embed(range: PartialRangeUpTo<Int>, in color: Color) -> String? {
        let coloredSubstring = String(self[range])
        return coloredSubstring.applyingColor(color) + self[range.upperBound...]
    }
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}

extension StringProtocol {
    subscript(range: CountableRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)

        if self.count > range.upperBound {
            return self[startIndex..<index(startIndex, offsetBy: range.count)]
        } else {
            return self[startIndex..<self.endIndex]
        }
    }
    
    subscript(range: CountablePartialRangeFrom<Int>) -> SubSequence {
        self[index(startIndex, offsetBy: range.lowerBound)...]
    }
    
    subscript(range: PartialRangeThrough<Int>) -> SubSequence {
        self[...index(startIndex, offsetBy: range.upperBound)]
    }
    
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence {
        self[..<index(startIndex, offsetBy: range.upperBound)]
    }
}

extension String {
    mutating func paintTimestamp() {
        self = paintedTimestamp()
    }
    
    func paintedTimestamp() -> String {
        if hasPrefix("2019") {
            return embed(range: ..<30 , in: .yellow) ?? self
        }
        return self
    }
}

let main = command(
    Argument<String>("log", description: "input .log file")
) { log in
    let start = DispatchTime.now()
    
    do {
        let data = try String(contentsOfFile: log, encoding: .utf8)
        let logLines = data.components(separatedBy: .newlines)
        
        upperFor: for line in logLines {
            if line.isEmpty {
                continue
            }
            // TODO: this will stop working in 1 month
            if line.hasPrefix("2019") {
                for suffix in suffixes {
                    if line[31 ..< 31 + suffix.count] == suffix {
                        if let coloredLogLine = line.embed(wordContainingSubstring: suffix, in: colors[suffix] ?? .default) {
                            print(coloredLogLine.paintedTimestamp())
                            continue upperFor
                        }
                    }
                }
            }
            
            print(line.paintedTimestamp())
        }
    } catch {
        print(error)
    }
    
    let end = DispatchTime.now()

    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
    let timeInterval = Double(nanoTime) / 1_000_000_000

    print("\(timeInterval) seconds wasted painting logs 🚀".lightBlue)
}

main.run()

