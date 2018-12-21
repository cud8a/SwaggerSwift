//
//  ViewController.swift
//  Loco
//
//  Created by Tamas Bara on 19.12.18.
//  Copyright © 2018 de.check24. All rights reserved.
//

import Cocoa
import Fragaria

class ViewController: NSViewController {

    @IBOutlet weak var fragariaView: MGSFragariaView!
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var splitView: NSSplitView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fragariaView.showsGutter = false
        fragariaView.syntaxDefinitionName = "Javascript"
        fragariaView.textView.string = """
        {
            "id": 0,
            "valid": true,
            "geb_datum": "01.01.1988",
            "bar": {
                "foo": "hallo"
            }
        }
        """
        splitView.setPosition(300, ofDividerAt: 0)
        generateClicked(self)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func pasteClicked(_ sender: Any) {
        if let swagger = NSPasteboard.general.pasteboardItems?.first?.string(forType: .string) {
            fragariaView.textView.string = swagger
        }
    }
    
    @IBAction func generateClicked(_ sender: Any) {
        do {
            if let data = fragariaView.textView.string.data(using: .utf8), let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] {
                
                var items: [NSTabViewItem] = []
                for (name, code) in SwiftGenerator.generate(json) {
                    let textView = SMLTextView(frame: tabView.contentRect)
                    textView.syntaxColouring.syntaxDefinitionName = "Swift"
                    textView.string = code
                    //textView.font = NSFont(name: "Menlo", size: 12)
                    textView.autoresizingMask = .width
                    textView.minSize = NSSize(width: 0, height: tabView.contentRect.height)
                    textView.maxSize = NSSize(width: CGFloat(Float.greatestFiniteMagnitude), height: CGFloat(Float.greatestFiniteMagnitude))
                    textView.isHorizontallyResizable = false
                    textView.isVerticallyResizable = true
                    let tabViewItem = NSTabViewItem()
                    tabViewItem.label = name
                    let scrollView = NSScrollView(frame: tabView.contentRect)
                    scrollView.documentView = textView
                    scrollView.hasVerticalScroller = true
                    scrollView.autoresizingMask = [.width, .height]
                    tabViewItem.view = scrollView
                    items.append(tabViewItem)
                }
                
                tabView.tabViewItems = items
            }
        } catch {
            // handle error
        }
    }
    
    @IBAction func copyClicked(_ sender: Any) {
        if let scrollView = tabView.selectedTabViewItem?.view as? NSScrollView, let textView = scrollView.documentView as? NSTextView {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(textView.string, forType: .string)
        }
    }
}


