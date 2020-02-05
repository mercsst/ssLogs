import Foundation
import Commander
import Rainbow

let applicationName = "BLEConnect(DebugKit)"
let applicationNamePosition: Int = "MMM DD HH:mm:SS iPhone ".count

var colors: Dictionary<String, Color> = [
    "SS" : .lightBlue,
    "SL" : .lightBlue,
    "CM" : .green,
    "Certificate" : .green,
    "FU" : .magenta,
    "GASP" : .cyan,
    "ServiceCP" : .cyan,
    "*** Assertion failure": .red
]

func prefixes() -> Array<String> {
    return Array(colors.keys)
}

func colors(from file: String?) {
    if let file = file,
        let string = try? String(contentsOfFile: file, encoding: .utf8),
        let data = string.data(using: .utf8) {

        print("received config \(string)")
        print("")
        if let parsedColor = try? JSONDecoder().decode(Dictionary<String, Color>.self, from: data) {
            colors = parsedColor
        }
    }
}

enum LogType {
    case device
    case application
    case undetermined
}

var logType: LogType = .undetermined
func determineLogType(logLine: String) -> LogType {
    if logLine.prefixedWithYear() {
        return .application
    } else if logLine.prefixedWithMonth() {
        return .device
    } else {
        return .undetermined
    }
}

extension String {
    static var classNamePosition: Int = {
        switch logType {
        case .undetermined:
            assertionFailure("Log type should be determined at this point")
            return 0
        case .application:
            return "2020-01-29 15:51:00.130 +0200: ".count
        case .device:
            return "MMM DD HH:mm:SS iPhone BLEConnect(DebugKit)[291] <Notice>: ".count //TODO: this might vary actually
        }
    }()
}

let main = command(
    Option<String?>("configFile", default: Optional<String>.none, description: """
Configuration file with JSON dictionary in format: {<class name or prefix> : color}.
Valid colors are 30-39 and 90-99 or "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white", "lightBlack", "lightRed", "lightGreen", "lightYellow", "lightBlue", "lightMagenta", "lightCyan", "lightWhite".
"""),
    Argument<String>("log", description: "input .log file")
) { configFile, log in
    let start = DispatchTime.now()

    colors(from: configFile)

    do {
        let data = try String(contentsOfFile:  log, encoding: .utf8)
        let logLines = data.components(separatedBy: .newlines)
        
        var shouldPrintSuplementaryLines = false
        upperFor: for line in logLines {
            if line.isEmpty {
                continue
            }

            logType = determineLogType(logLine: line)
            if logType != .undetermined {
                if logType == .device {
                    if line[applicationNamePosition ..< applicationNamePosition + applicationName.count] != applicationName {
                        shouldPrintSuplementaryLines = false
                        continue
                    }
                }

                shouldPrintSuplementaryLines = true
                for prefix in prefixes() {
                    if line[String.classNamePosition ..< String.classNamePosition + prefix.count] == prefix {
                        if let coloredLogLine = line.embed(wordContainingSubstring: prefix,
                                                           in: colors[prefix] ?? .default,
                                                           at: String.classNamePosition) {
                            // Found string that contains searched class name
                            print(coloredLogLine.paintedTimestamp())
                            continue upperFor
                        }
                    }
                }
                // string doesn't contain searched class name but is printed by right application
                print(line.paintedTimestamp())
                continue
            } else {
                if shouldPrintSuplementaryLines {
                    print(line)
                }
            }
        }
    } catch {
        print("\(error)".applyingColor(.red))
    }
    
    let end = DispatchTime.now()

    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
    let timeInterval = Double(nanoTime) / 1_000_000_000

    print("\(timeInterval) seconds wasted painting logs 🚀".lightBlue)
}



main.run()
