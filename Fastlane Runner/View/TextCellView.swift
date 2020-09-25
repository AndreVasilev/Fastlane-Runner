//
//  TextCellView.swift
//  Fastlane Runner
//
//  Created by Andrey Vasilev on 18.08.2020.
//  Copyright © 2020 Vasilev. All rights reserved.
//

import Cocoa

class TextCellView: NSTableCellView {

    static let identifier = NSUserInterfaceItemIdentifier(rawValue: "TextCellView")

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

    override func menu(for event: NSEvent) -> NSMenu? {
        print(event.type.rawValue)
        return super.menu(for: event)
    }
}
