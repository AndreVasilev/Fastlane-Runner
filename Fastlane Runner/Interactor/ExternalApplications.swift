//
//  ExternalApplications.swift
//  Fastlane Runner
//
//  Created by Andrey Vasilev on 09.10.2020.
//  Copyright © 2020 Vasilev. All rights reserved.
//

import Foundation
import AppKit

struct ExteranlApplications {
    static var sublime: URL? {
        return ["com.sublimetext.4", "com.sublimetext.3"]
            .compactMap { NSWorkspace.shared.urlForApplication(withBundleIdentifier: $0) }
            .first
    }
    static var textEdit: URL? { NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.TextEdit") }
}
