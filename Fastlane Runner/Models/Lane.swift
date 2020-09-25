//
//  Lane.swift
//  Fastlane Runner
//
//  Created by Andrey Vasilev on 18.08.2020.
//  Copyright © 2020 Vasilev. All rights reserved.
//

import Foundation

struct Lane: Codable {
    let name: String
    let arguments: [String]?
    let execPath: String
    var isFavorite: Bool = false
}

extension Lane: Equatable {

    static func == (lhs: Lane, rhs: Lane) -> Bool {
        return lhs.name == rhs.name
            && lhs.arguments == rhs.arguments
            && lhs.execPath == rhs.execPath
            && lhs.isFavorite == rhs.isFavorite
    }
}
