//
//  Interactor.swift
//  Fastlane Runner
//
//  Created by Andrey Vasilev on 21.08.2020.
//  Copyright © 2020 Vasilev. All rights reserved.
//

import Foundation

class Interactor {

    private let database: IDatabase = Database()

    func runLane(_ lane: String, projectDirectory path: String) {
        let cdCmd = "cd '\(path)'"
        let fastlaneCmd = "bundle exec fastlane \(lane)"
        let cmd = "\(cdCmd); \(fastlaneCmd)"
        executeCommand(cmd, quit: false)
    }

    func openInFinder(fileAt path: String) {
        let cmd = "open -R '\(path)'"
        executeCommand(cmd, quit: true)
    }

    func openInSublime(fileAt path: String) {
        let cmd = "sublime '\(path)'"
        executeCommand(cmd, quit: true)
    }

    func openInTextEdit(fileAt path: String) {
        let cmd = "open '\(path)'"
        executeCommand(cmd, quit: true)
    }

    func getFastfiles() -> [Fastfile] {
        return database.getFastfiles()
    }

    func updateFastfiles(_ files: [Fastfile]) {
        database.updateFastfiles(files)
    }
}

private extension Interactor {

    func executeCommand(_ cmd: String, quit: Bool) {
        let script = """
        tell application \"Terminal\"
            do script "\(cmd)\(quit ? "; exit;" : "")"
            \(quit ? "delay 1" : "")
            \(quit ? "close window 1" : "")
        end tell
        """

        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?
        appleScript?.executeAndReturnError(&error)
        if let error = error {
            print(error)
        }
    }
}
