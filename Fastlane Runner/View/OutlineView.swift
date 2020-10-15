//
//  OutlineView.swift
//  Fastlane Runner
//
//  Created by Andrey Vasilev on 21.08.2020.
//  Copyright © 2020 Vasilev. All rights reserved.
//

import Cocoa

protocol MenuDelegate: NSOutlineViewDelegate {
    func run(_ sender: NSMenuItem)
    func openInFinder(_ sender: NSMenuItem)
    func openInSublime(_ sender: NSMenuItem)
    func openInTextEdit(_ sender: NSMenuItem)
    func addToFavorite(_ sender: NSMenuItem)
    func removeFromFavorite(_ sender: NSMenuItem)
    func remove(_ sender: NSMenuItem)
}

class OutlineView: NSOutlineView {

    override func menu(for event: NSEvent) -> NSMenu? {
        var menu = super.menu(for: event)
        menu?.removeAllItems()
        let point = convert(event.locationInWindow, from: nil)
        let clickedRow = row(at: point)
        let item = self.item(atRow: clickedRow)
        if item is Fastfile {
            menu?.addItem(NSMenuItem(title: "Show in Finder", action: #selector(openInFinder(_:)), keyEquivalent: ""))
            if ExteranlApplications.sublime != nil {
                menu?.addItem(NSMenuItem(title: "Open in Sublime", action: #selector(openInSublime(_:)), keyEquivalent: ""))
            }
            if ExteranlApplications.textEdit != nil {
                menu?.addItem(NSMenuItem(title: "Open in TextEdit", action: #selector(openInTextEdit(_:)), keyEquivalent: ""))
            }
            menu?.addItem(NSMenuItem(title: "Remove", action: #selector(remove(_:)), keyEquivalent: ""))
        } else if let lane = item as? Lane {
            menu?.addItem(NSMenuItem(title: "Run 🚀", action: #selector(run(_:)), keyEquivalent: ""))
            if lane.isFavorite {
                menu?.addItem(NSMenuItem(title: "Remove from Favorite", action: #selector(removeFromFavorite(_:)), keyEquivalent: ""))
            } else {
                menu?.addItem(NSMenuItem(title: "Add to Favorite", action: #selector(addToFavorite(_:)), keyEquivalent: ""))
            }
        } else {
            menu = nil
        }
        return menu
    }

    @objc func run(_ sender: NSMenuItem) {
        (delegate as? MenuDelegate)?.run(sender)
    }

    @objc func openInFinder(_ sender: NSMenuItem) {
        (delegate as? MenuDelegate)?.openInFinder(sender)
    }

    @objc func openInSublime(_ sender: NSMenuItem) {
        (delegate as? MenuDelegate)?.openInSublime(sender)
    }

    @objc func openInTextEdit(_ sender: NSMenuItem) {
        (delegate as? MenuDelegate)?.openInTextEdit(sender)
    }

    @objc func addToFavorite(_ sender: NSMenuItem) {
        (delegate as? MenuDelegate)?.addToFavorite(sender)
    }

    @objc func removeFromFavorite(_ sender: NSMenuItem) {
        (delegate as? MenuDelegate)?.removeFromFavorite(sender)
    }

    @objc func remove(_ sender: NSMenuItem) {
        (delegate as? MenuDelegate)?.remove(sender)
    }

    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        super.willOpenMenu(menu, with: event)
    }

    override func didCloseMenu(_ menu: NSMenu, with event: NSEvent?) {
        super.didCloseMenu(menu, with: event)
    }
}
