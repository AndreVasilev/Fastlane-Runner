//
//  Interactor.swift
//  Fastlane Runner
//
//  Created by Andrey Vasilev on 21.08.2020.
//  Copyright © 2020 Vasilev. All rights reserved.
//

import Foundation
import AppKit

class Interactor {

    private let database: IDatabase = Database()

    func runLane(_ lane: String, projectDirectory path: String, foreground: Bool) {
        let cdCmd = "cd '\(path)'"
        let fastlaneCmd = "bundle exec fastlane \(lane)"
        let cmd = "\(cdCmd); \(fastlaneCmd)"
        executeTerminalCommand(cmd, quit: false, activate: foreground)
    }

    func openInFinder(fileAt url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    func openInSublime(fileAt url: URL) {
        guard let appUrl = ExteranlApplications.sublime else { return }
        NSWorkspace.shared.open([url], withApplicationAt: appUrl, configuration: NSWorkspace.OpenConfiguration()) { application, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    func openInTextEdit(fileAt url: URL) {
        guard let appUrl = ExteranlApplications.textEdit else { return }
        NSWorkspace.shared.open([url], withApplicationAt: appUrl, configuration: NSWorkspace.OpenConfiguration()) { application, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    func getFastfiles() -> [Fastfile] {
        return database.getFastfiles()
    }

    func updateFastfiles(_ files: [Fastfile]) {
        database.updateFastfiles(files)
    }
}

private extension Interactor {

    func executeTerminalCommand(_ cmd: String, quit: Bool, activate: Bool) {
        let script = """
        tell application \"Terminal\"
            do script "\(cmd)\(quit ? "; exit;" : "")"
            \(quit ? "delay 1" : "")
            \(quit ? "close window 1" : "")
            \(activate ? "activate" : "")
        end tell
        """

        executeScript(script)
    }

    func execute(app: String, open target: String) {
        let script = """
        tell application \"\(app)\"
            open \(target)
            activate
        end tell
        """
        executeScript(script)
    }

    func executeScript(_ script: String) {
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?
        appleScript?.executeAndReturnError(&error)
        if let error = error {
            print(error)
        }
    }
}
