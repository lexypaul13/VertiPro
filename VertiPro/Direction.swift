//
//  Direction.swift
//  VertiPro
//
//  Created by Alex Paul on 10/13/24.
//

import Foundation

enum Direction: String, CaseIterable, Codable {
    case up, down, left, right
    
    mutating func next() {
        switch self {
        case .up: self = .right
        case .right: self = .down
        case .down: self = .left
        case .left: self = .up
        }
    }
}
