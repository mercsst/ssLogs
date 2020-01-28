import Foundation
import Rainbow

extension Color {
    init?(_ string: String) {
        switch string {
        case "black":           self = .black
        case "red":             self = .red
        case "green":           self = .green
        case "yellow":          self = .yellow
        case "blue":            self = .blue
        case "magenta":         self = .magenta
        case "cyan":            self = .cyan
        case "white":           self = .white
        case "lightBlack":      self = .lightBlack
        case "lightRed":        self = .lightRed
        case "lightGreen":      self = .lightGreen
        case "lightYellow":     self = .lightYellow
        case "lightBlue":       self = .lightBlue
        case "lightMagenta":    self = .lightMagenta
        case "lightCyan":       self = .lightCyan
        case "lightWhite":      self = .lightWhite

        default:
            return nil
        }
    }
}

extension Color: Decodable {
    public init(from decoder: Decoder) throws {
        do {
            self = try Color(decoder.singleValueContainer().decode(String.self)) ?? .default
        } catch(DecodingError.typeMismatch) {
            do {
                self = try Color(rawValue: decoder.singleValueContainer().decode(UInt8.self)) ?? .default
            } catch(DecodingError.typeMismatch) {
                self = .default
            }
        }
    }
}
