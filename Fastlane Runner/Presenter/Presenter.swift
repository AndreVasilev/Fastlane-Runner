//
//  Presenter.swift
//  Fastlane Runner
//
//  Created by Andrey Vasilev on 18.08.2020.
//  Copyright © 2020 Vasilev. All rights reserved.
//

import Foundation

class Presenter {

    let interactor: Interactor = Interactor()

    lazy var files: [Fastfile] = interactor.getFastfiles()

    var itemsList: [Any] {
        var list = [Any]()
        for file in files {
            list.append(file)
            list.append(contentsOf: file.lanes)
        }
        return list
    }

    func addFile(url: URL) {
        if let fastfile = Fastfile(at: url),
            !files.contains(fastfile) {
            files.append(fastfile)
            interactor.updateFastfiles(files)
        }
    }

    func scanDirectory(url: URL, _ completion: @escaping () -> Void) {
        DispatchQueue(label: "parse_directory").async { [unowned self] in
            let files = self.scanDirectory(at: url)
            DispatchQueue.main.async {
                let newFiles = files.filter({ !self.files.contains($0) })
                if !newFiles.isEmpty {
                    self.files.append(contentsOf: newFiles)
                    self.interactor.updateFastfiles(files)
                }
                completion()
            }
        }
    }

    func reloadFastfiles(_ completion: @escaping () -> Void) {
        DispatchQueue(label: "reload").async { [unowned self] in
            let newFiles = self.files.compactMap { Fastfile(at: $0.url) }
            DispatchQueue.main.async {
                self.files = newFiles
                self.interactor.updateFastfiles(newFiles)
                completion()
            }
        }
    }

    func runLane(_ lane: Lane) {
        interactor.runLane(lane.name, projectDirectory: lane.execPath, foreground: true)
    }

    func openInFinder(fastfile: Fastfile) {
        interactor.openInFinder(fileAt: fastfile.url)
    }

    func openInSublime(fastfile: Fastfile) {
        interactor.openInSublime(fileAt: fastfile.url)
    }

    func openInTextEdit(fastfile: Fastfile) {
        interactor.openInTextEdit(fileAt: fastfile.url)
    }

    func setFavorite(_ favorite: Bool, lane: Lane) {
        files = files.map {
            if $0.lanes.contains(lane) {
                let lanes: [Lane] = $0.lanes.map {
                    if $0 == lane {
                        var newLane = lane
                        newLane.isFavorite = favorite
                        return newLane
                    } else {
                        return $0
                    }
                }
                return Fastfile(url: $0.url, lanes: lanes)
            } else {
                return $0
            }
        }
        interactor.updateFastfiles(files)
    }

    func removeFastfile(_ file: Fastfile) {
        files = files.filter { $0 != file }
        interactor.updateFastfiles(files)
    }
}

private extension Presenter {

    func scanDirectory(at url: URL) -> [Fastfile] {
        var files = [Fastfile]()
        let fileManager = FileManager.default
        let contents = (try? fileManager.contentsOfDirectory(atPath: url.path)) ?? []
        for name in contents {
            let path = url.appendingPathComponent(name).path
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: path, isDirectory: &isDirectory) {
                let url = URL(fileURLWithPath: path, isDirectory: isDirectory.boolValue)
                if isDirectory.boolValue {
                    files.append(contentsOf: scanDirectory(at: url))
                } else if let file = Fastfile(at: url) {
                    files.append(file)
                }
            }
        }
        return files
    }
}
