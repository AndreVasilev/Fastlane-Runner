//
//  ViewController.swift
//  Fastlane Runner
//
//  Created by Andrey Vasilev on 06.08.2020.
//  Copyright © 2020 Vasilev. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var chooseButton: NSButton!
    @IBOutlet weak var scanButton: NSButton!

    private let presenter: Presenter = Presenter()
}

private extension ViewController {

    @IBAction func chooseFile(_ sender: NSButton) {
        let dialog = NSOpenPanel();

        dialog.title = "Choose Fastfile"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = true
        dialog.allowsMultipleSelection = false
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false

        if (dialog.runModal() == .OK) {
            if let result = dialog.url {
                progressIndicator.startAnimation(self)
                presenter.addFile(url: result)
                progressIndicator.stopAnimation(self)
                reloadData()
            }
        }
    }

    @IBAction func scanDirectory(_ sender: NSButton) {
        let dialog = NSOpenPanel();

        dialog.title = "Scan directory"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = true
        dialog.allowsMultipleSelection = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true

        if (dialog.runModal() == .OK) {
            if let result = dialog.url {
                callBackgroundTask { [weak self] completion in
                    self?.presenter.scanDirectory(url: result, completion)
                }
            }
        }
    }

    @IBAction func reload(_ sender: NSButton) {
        callBackgroundTask(presenter.reloadFastfiles)
    }

    @IBAction func doubleClickAction(_ sender: Any) {
        let row = outlineView.clickedRow
        let column = outlineView.clickedColumn
        guard let item = outlineView.item(atRow: row) else { return }
        if let file = item as? Fastfile {
            switch column {
            case 0: presenter.openInSublime(fastfile: file)
            case 1: presenter.openInFinder(fastfile: file)
            default: break
            }
        } else if let lane = item as? Lane {
            switch column {
            case 0: presenter.runLane(lane)
            default: break
            }
        }
    }

    func reloadData() {
        outlineView.reloadData()
    }

    func callBackgroundTask(_ task: (@escaping () -> Void) -> Void) {
        progressIndicator.startAnimation(self)
        chooseButton.isEnabled = false
        scanButton.isEnabled = false
        task { [weak self] in
            self?.progressIndicator.stopAnimation(self)
            self?.reloadData()
            self?.chooseButton.isEnabled = true
            self?.scanButton.isEnabled = true
        }
    }
}

// MARK: Menu

extension ViewController: MenuDelegate {

    func run(_ sender: NSMenuItem) {
        let row = outlineView.clickedRow
        guard let item = outlineView.item(atRow: row) as? Lane else { return }
        presenter.runLane(item)
    }

    func openInFinder(_ sender: NSMenuItem) {
        let row = outlineView.clickedRow
        guard let item = outlineView.item(atRow: row) as? Fastfile else { return }
        presenter.openInFinder(fastfile: item)
    }

    func openInSublime(_ sender: NSMenuItem) {
        let row = outlineView.clickedRow
        guard let item = outlineView.item(atRow: row) as? Fastfile else { return }
        presenter.openInSublime(fastfile: item)
    }

    func openInTextEdit(_ sender: NSMenuItem) {
        let row = outlineView.clickedRow
        guard let item = outlineView.item(atRow: row) as? Fastfile else { return }
        presenter.openInTextEdit(fastfile: item)
    }

    func addToFavorite(_ sender: NSMenuItem) {
        let row = outlineView.clickedRow
        guard let item = outlineView.item(atRow: row) as? Lane else { return }
        presenter.setFavorite(true, lane: item)
        reloadData()
    }

    func removeFromFavorite(_ sender: NSMenuItem) {
        let row = outlineView.clickedRow
        guard let item = outlineView.item(atRow: row) as? Lane else { return }
        presenter.setFavorite(false, lane: item)
        reloadData()
    }

    func remove(_ sender: NSMenuItem) {
        let row = outlineView.clickedRow
        guard let item = outlineView.item(atRow: row) as? Fastfile else { return }
        presenter.removeFastfile(item)
        reloadData()
    }
}

extension ViewController: NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let fastfile = item as? Fastfile {
            return fastfile.lanes.count
        } else {
            return presenter.files.count
        }
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let fastfile = item as? Fastfile {
            return fastfile.lanes[index]
        } else {
            return presenter.files[index]
        }
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is Fastfile
    }
}

extension ViewController: NSOutlineViewDelegate {

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let view = outlineView.makeView(withIdentifier: TextCellView.identifier, owner: self) as? TextCellView
        if let fastfile = item as? Fastfile {
            switch tableColumn?.title {
            case "Name":
                view?.textField?.stringValue = fastfile.name
            case "Path":
                view?.textField?.stringValue = fastfile.directory
            default:
                view?.textField?.stringValue = ""
            }
        } else if let lane = item as? Lane {
            switch tableColumn?.title {
            case "Name":
                view?.textField?.stringValue = lane.name
            default:
                view?.textField?.stringValue = ""
            }
        }
        view?.textField?.sizeToFit()
        return view
    }
}
