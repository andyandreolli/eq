//
//  PanelViewController.swift
//  ēq
//
//  Created by Andrea Andreolli on 18/05/15.
//  Copyright (c) 2015 Andrea Andreolli. All rights reserved.
//

import Cocoa
import WebKit
let eqImage: Bool = true
let latexCode: Bool = false

class PanelViewController: NSViewController {
    
    @IBOutlet var pic: NSImageView! //shows the image containing the equation
    @IBOutlet var box: NSTextField! //fields where the user inserts latex code
    @IBOutlet var switchButton: NSButton! //toggles settings
    @IBOutlet var mainView: NSView! //contains pic and box
    @IBOutlet var settingsView: NSView! //contains settings
    @IBOutlet var stgsButton1: NSButton! //selects what is being copied to clipboard
    @IBOutlet var stgsPopup1: NSPopUpButton! //selects image size
    @IBOutlet var shortcutView: MASShortcutView! //captures user chosen global shortcut
    
    var clipboard = NSPasteboard.generalPasteboard()
    var defaults = NSUserDefaults.standardUserDefaults()
    
    var settings: Bool = false //if true, settings are shown
    
    
    
    func loadURL (eq: String) //takes latex code as input; downloads, displays and copies to clipboard the equation image
    {
        
        //first the URLs are generated
        var req = "http://latex.codecogs.com/png.latex?\\dpi{" + String(defaults.integerForKey("imgSize")) + "}&space;" + eq //HQ image that will be printed on screen
        var cpy = "http://latex.codecogs.com/png.latex?\\dpi{200}&space;" + eq //smaller image that will be copied to clipboard
        
        //strings containing URLs are then encoded with allowed characters only
        req = req.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
        cpy = cpy.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
        
        //strings are converted to NSURL type
        let requesturl = NSURL (string: req)
        let cpyurl = NSURL(string: cpy)
        //and then downloaded
        let data = NSData(contentsOfURL: requesturl!)
        let cpydata = NSData(contentsOfURL: cpyurl!)
        
        //if something has actually been downloaded, it gets printed to screen
        if data != nil {
            pic.image = NSImage(data: data!)
            if defaults.boolForKey("isCopied") == eqImage //the low quality image is copied to clipboard if required
            {
                var obj: NSObject = NSArray (object: NSImage(data: cpydata!)!)
                clipboard.clearContents()
                clipboard.writeObjects (obj as! [AnyObject])
            }
        }
        
    }

    
    
    override func viewDidLoad() //executed when view is loaded for the first time
    {
        
        super.viewDidLoad()
        
        box.becomeFirstResponder() //sets focus to box
        self.shortcutView.associatedUserDefaultsKey = "GlobalShortcut"; //tells the program to listen for the shortcut stored at key "GlobalShortcut"
        
        defaults.synchronize() //loads defaults from disk
        if defaults.objectForKey("isCopied") == nil //this key tells whether the image or the latex code is copied to clipboard
        {
            defaults.setBool(eqImage, forKey: "isCopied") //the key is generated if not existing
            defaults.synchronize()
        }
        else if defaults.boolForKey("isCopied") == latexCode
        {
            stgsButton1.title = "latex code"
        }
        
        if defaults.objectForKey("imgSize") == nil //this key tells the size of the displayed image
        {
            defaults.setInteger(900, forKey: "imgSize") //the key is generated if not existing
            defaults.synchronize()
            stgsPopup1.selectItemAtIndex(2) //selects correct object in the settings' popup list
        }
            
        else {
            stgsPopup1.selectItemAtIndex(defaults.integerForKey("imgSize")/300 - 1) //selects correct object in the settings' popup list
        }
        
    }
    
}




extension PanelViewController {
    
    
    @IBAction func updateImage (sender: NSTextField) //run when user presses enter
    
    {
        
        //box content is loaded as a string
        var proeq: String
        proeq = box.stringValue
        
        //latex code is copied to clipboard if necessary
        if defaults.boolForKey("isCopied") == latexCode {
            clipboard.clearContents()
            clipboard.setString(proeq, forType: NSStringPboardType)
        }
        
        proeq = proeq.stringByReplacingOccurrencesOfString(" ", withString: "&space;", options: NSStringCompareOptions.LiteralSearch, range: nil) //replaces spaces with string
        
        loadURL(proeq) //displays URL containing image
        
    }
    
    
    @IBAction func openSettings (sender: NSButton) //called when settings button is pressed; hides or displays main view/settings view
    
    {
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
    
    
    @IBAction func setImageSize (sender: NSPopUpButton) //called on edit of the popup button in the settings view
        
    {
        switch stgsPopup1.indexOfSelectedItem //assigns value to defaults key "imgsize" depending on user's choice
        {
        case 0:
            defaults.setInteger(300, forKey: "imgSize")
        case 1:
            defaults.setInteger(600, forKey: "imgSize")
        case 2:
            defaults.setInteger(900, forKey: "imgSize")
        default:
            defaults.setInteger(900, forKey: "imgSize")
            stgsPopup1.selectItemAtIndex(2)
        }
        defaults.synchronize()
    }
    
    
    @IBAction func switchCopyMode (sender: NSButton) //called on click on stgsbutton1
    
    {
        
        //defaults key "isCopied" is assigned its opposite value
        let boolToBeReverted: Bool = defaults.boolForKey ("isCopied")
        defaults.setBool(!boolToBeReverted, forKey: "isCopied")
        defaults.synchronize()
        
        //adjusts stgsbutton1's title
        if !boolToBeReverted {
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