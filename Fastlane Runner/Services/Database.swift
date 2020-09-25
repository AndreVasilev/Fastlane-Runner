//
//  Database.swift
//  Fastlane Runner
//
//  Created by Andrey Vasilev on 19.08.2020.
//  Copyright © 2020 Vasilev. All rights reserved.
//

import Foundation

protocol IDatabase {
    func getFastfiles() -> [Fastfile]
    func updateFastfiles(_ files: [Fastfile])
}

class Database {

    let fastfilesKey = "fastfilesKey"
}

extension Database: IDatabase {

    func getFastfiles() -> [Fastfile] {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: fastfilesKey),
            let files = try? decoder.decode([Fastfile].self, from: data) {
            return files
        } else {
            return []
        }
    }

    func updateFastfiles(_ files: [Fastfile]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(files) {
            UserDefaults.standard.set(data, forKey: fastfilesKey)
            UserDefaults.standard.synchronize()
        }
    }
}
