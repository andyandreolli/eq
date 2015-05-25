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
    
    @IBOutlet var pic: NSImageView!
    @IBOutlet var box: NSTextField!
    @IBOutlet var switchButton: NSButton!
    @IBOutlet var mainView: NSView!
    @IBOutlet var settingsView: NSView!
    @IBOutlet var stgsButton1: NSButton!
    @IBOutlet var stgsPopup1: NSPopUpButton!

    var clipboard = NSPasteboard.generalPasteboard()
    var defaults = NSUserDefaults.standardUserDefaults()
    
    var copyIMG: Bool = true
    var settings: Bool = false
    var imgSize: Int = 600
    
    func loadURL (eq: String) {
        var req = "http://latex.codecogs.com/png.latex?\\dpi{" + String(imgSize) + "}&space;" + eq
        var cpy = "http://latex.codecogs.com/png.latex?\\dpi{200}&space;" + eq
        req = req.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
        cpy = cpy.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
        let requesturl = NSURL (string: req)
        let cpyurl = NSURL(string: cpy)
        let data = NSData(contentsOfURL: requesturl!)
        let cpydata = NSData(contentsOfURL: cpyurl!)
        if data != nil {
            pic.image = NSImage(data: data!)
            if copyIMG {
                var obj: NSObject = NSArray (object: NSImage(data: cpydata!)!)
                clipboard.clearContents()
                clipboard.writeObjects (obj as! [AnyObject])
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        box.becomeFirstResponder()
        defaults.synchronize()
        if defaults.boolForKey("isCopied") == false {
            copyIMG = false
            stgsButton1.title = "latex code"
        }
        if defaults.objectForKey("imgSize") != nil {
            imgSize = defaults.integerForKey("imgSize")
            stgsPopup1.selectItemAtIndex(imgSize/300 - 1)
        }
    }
    
}

extension PanelViewController {
    
    @IBAction func updateImage (sender: NSTextField) {
        var proeq: String
        proeq = box.stringValue
        if !copyIMG {
            clipboard.clearContents()
            clipboard.setString(proeq, forType: NSStringPboardType)
        }
        proeq = proeq.stringByReplacingOccurrencesOfString(" ", withString: "&space;", options: NSStringCompareOptions.LiteralSearch, range: nil)
        loadURL(proeq)
    }
    
    @IBAction func openSettings (sender: NSButton) {
        if !settings {
            mainView.hidden = !mainView.hidden
            settingsView.hidden = !settingsView.hidden
        }
        else {
            settingsView.hidden = !settingsView.hidden
            mainView.hidden = !mainView.hidden
            box.becomeFirstResponder()
        }
        
        settings = !settings
        
        if settings {
            switchButton.title = "Close settings"
        }
        else {
            switchButton.title = "Settings"
        }
    }
    
    @IBAction func setImageSize (sender: NSPopUpButton) {
        switch stgsPopup1.indexOfSelectedItem {
        case 0:
            imgSize = 300
        case 1:
            imgSize = 600
        case 2:
            imgSize = 900
        default:
            imgSize = 600
            stgsPopup1.selectItemAtIndex(1)
        }
        defaults.setInteger(imgSize, forKey: "imgSize")
    }
    
    @IBAction func switchCopyMode (sender: NSButton) {
        copyIMG = !copyIMG
        defaults.setBool(copyIMG, forKey: "isCopied")
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