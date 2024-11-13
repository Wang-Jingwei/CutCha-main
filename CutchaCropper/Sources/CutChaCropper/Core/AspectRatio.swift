//
//  AspectRatio.swift
//
//  Created by Chen Qizhi on 2019/10/16.
//

import Foundation

public enum AspectRatio {
    case freeForm
    case ratio(width: Int, height: Int)

    var description: String {
        switch self {
        case .freeForm:
            return "FREE"
        case let .ratio(width, height):
            return "\(width):\(height)"
        }
    }
    
    var getRatio: (Double,Double) {
        switch self {
        case .freeForm:
            return (0.75, 0.75)
        case let .ratio(width, height):
            if width > height {
                return (1.0, Double(height)/Double(width))
            } else if height > width {
                return (Double(width)/Double(height), 1.0)
            }
            else {
                return (1.0,1.0)
            }
        }
    }
}

// MARK: Codable

extension AspectRatio: Codable {
    enum CodingKeys: String, CodingKey {
        case description
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let desc = try container.decodeIfPresent(String.self, forKey: .description) else {
            self = .freeForm
            return
        }
        switch desc {
        case "FREE":
            self = .freeForm
        default:
            let numberStrings = desc.split(separator: ":")
            if numberStrings.count == 2,
                let width = Int(numberStrings[0]),
                let height = Int(numberStrings[1]) {
                self = .ratio(width: width, height: height)
            } else {
                self = .freeForm
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(description, forKey: .description)
    }
}

extension AspectRatio: Equatable {
    public static func == (lhs: AspectRatio, rhs: AspectRatio) -> Bool {
        switch (lhs, rhs) {
        case (let .ratio(lhsWidth, lhsHeight), let .ratio(rhsWidth, rhsHeight)):
            return lhsWidth == rhsWidth && lhsHeight == rhsHeight
        case (.freeForm, .freeForm):
            return true
        default:
            return false
        }
    }
}
