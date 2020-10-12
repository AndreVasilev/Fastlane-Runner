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
    static var sublime: URL? { NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.sublimetext.3") }
    static var textEdit: URL? { NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.TextEdit") }
}
