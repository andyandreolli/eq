//
//  PanelViewController.swift
//  ēq
//
//  Created by Andrea Andreolli on 18/05/15.
//  Copyright (c) 2015 Andrea Andreolli. All rights reserved.
//

import Cocoa
import WebKit


class PanelViewController: NSViewController {
    
    
    @IBOutlet var settingsView: NSView!
    @IBOutlet var stgsButton1: NSButton!
    @IBOutlet var stgsPopup1: NSPopUpButton!

    var defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        if !defaults.boolForKey("eq.copyIMG") {
            stgsButton1.title = "latex code"
        }
        if defaults.objectForKey("eq.imgSize") != nil {
            stgsPopup1.selectItemAtIndex(defaults.integerForKey("eq.imgSize")/300 - 1)
        }
    }
    
}

extension PanelViewController {
    
    @IBAction func setImageSize (sender: NSPopUpButton) {
        switch stgsPopup1.indexOfSelectedItem {
        case 0:
            defaults.setInteger(300, forKey: "eq.imgSize")
        case 1:
            defaults.setInteger(600, forKey: "eq.imgSize")
        case 2:
            defaults.setInteger(900, forKey: "eq.imgSize")
        default:
            defaults.setInteger(900, forKey: "eq.imgSize")
            stgsPopup1.selectItemAtIndex(2)
        }
        defaults.synchronize()
    }
    
    @IBAction func switchCopyMode (sender: NSButton) {
        let copyIMG = !defaults.boolForKey("eq.copyIMG")
        defaults.setBool(copyIMG, forKey: "eq.copyIMG")
        defaults.synchronize()
        if copyIMG {
            stgsButton1.title = "equation"
        }
        else {
            stgsButton1.title = "latex code"
        }
    }
    
    @IBAction func quit (sender: NSButton) {
        NSApplication.sharedApplication().terminate(sender)
    }
    
}