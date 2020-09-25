//
//  FastfileModel.swift
//  Fastlane Runner
//
//  Created by Andrey Vasilev on 18.08.2020.
//  Copyright © 2020 Vasilev. All rights reserved.
//

import Foundation

struct Fastfile: Codable {

    let url: URL
    let lanes: [Lane]

    var name: String {
        return url.projectURL.lastPathComponent
    }

    var directory: String {
        return url.projectURL.path
    }

    init?(at url: URL) {
        guard url.isFastfile,
            let lanes = Fastfile.extractLanes(fileAt: url)
            else { return nil }
        self.init(url: url, lanes: lanes)
    }

    init(url: URL, lanes: [Lane]) {
        self.url = url
        self.lanes = lanes
    }
}

extension Fastfile: Equatable {

    static func == (lhs: Fastfile, rhs: Fastfile) -> Bool {
        return lhs.url == rhs.url
    }
}

private extension Fastfile {

    static func extractLanes(fileAt url: URL) -> [Lane]? {
        guard let text = try? String(contentsOf: url) else { return nil }
        let regex = try! NSRegularExpression(pattern: "(?<=lane\\s:)[^\\n]+", options: .allowCommentsAndWhitespace)
        let range = (text as NSString).range(of: text)
        let matches = regex.matches(in: text, options: .withoutAnchoringBounds, range: range)
        return matches.map { (text as NSString).substring(with: $0.range) }
            .compactMap {
                let components = $0.components(separatedBy: " do")
                guard let lane = components.first else { return nil }
                var arguments: [String]?
                if components.count == 2 && !components[1].isEmpty {
                    arguments = components.last?
                        .replacingOccurrences(of: " |", with: "")
                        .replacingOccurrences(of: "|", with: "")
                        .components(separatedBy: ",")
                }
                return Lane(name: lane, arguments: arguments, execPath: url.projectURL.path)
            }
    }
}

// MARK: URL extension

fileprivate extension URL {

    var isFastfile: Bool {
        return lastPathComponent == "Fastfile"
    }

    var projectURL: URL {
        return deletingLastPathComponent().deletingLastPathComponent()
    }


}
