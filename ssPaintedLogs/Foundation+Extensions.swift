import Foundation
import Rainbow

extension String {
    func embed(wordContainingSubstring word: String, in color: Color, at position: Int = -1) -> String? {
        let startOfWord: String.Index, endOfWord: String.Index
        if position != -1 {
            startOfWord = String.Index(utf16Offset: position, in: self)
            endOfWord = self[startOfWord...].range(of: " ")?.upperBound ?? endIndex
        } else if let rangeOfWord = self.range(of: word) {
            startOfWord = rangeOfWord.lowerBound
            endOfWord = self[rangeOfWord.upperBound...].range(of: " ")?.upperBound ?? endIndex
        } else {
            return nil
        }
        let coloredSubstring = String(self[startOfWord...index(before: endOfWord)])
        return self[..<startOfWord]
            + coloredSubstring.applyingColor(color)
            + self[endOfWord...]
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

let monthsShort = { () -> [String] in
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en")
    return formatter.shortMonthSymbols
}()

extension StringProtocol {
    func prefixedWithMonth() -> Bool {
        return monthsShort.contains(String(self[0 ..< 3]))
    }

    func prefixedWithYear() -> Bool {
        return String(self[0 ..< 2]) == "20"
    }
}

extension String {
    mutating func paintTimestamp() {
        self = paintedTimestamp()
    }
    
    func paintedTimestamp() -> String {
        if self.count > 23 {
            return embed(range: ..<23 , in: .yellow) ?? self
        }
        return self
    }
}
