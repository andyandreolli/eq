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
    
    var clipboard = NSPasteboard.general()
    var defaults = UserDefaults.standard
    
    var settings: Bool = false //if true, settings are shown
    
    
    
    func loadURL (_ eq: String) //takes latex code as input; downloads, displays and copies to clipboard the equation image
    {
        
        //first the URLs are generated
        var req = "http://latex.codecogs.com/png.latex?\\dpi{" + String(defaults.integer(forKey: "imgSize")) + "}&space;" + eq //HQ image that will be printed on screen
        var cpy = "http://latex.codecogs.com/png.latex?\\dpi{200}&space;" + eq //smaller image that will be copied to clipboard
        
        //strings containing URLs are then encoded with allowed characters only
        req = req.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)!
        cpy = cpy.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)!
        
        //strings are converted to NSURL type
        let requesturl = URL (string: req)
        let cpyurl = URL(string: cpy)
        //and then downloaded
        let data = try? Data(contentsOf: requesturl!)
        let cpydata = try? Data(contentsOf: cpyurl!)
        
        //if something has actually been downloaded, it gets printed to screen
        if data != nil {
            pic.image = NSImage(data: data!)
            if defaults.bool(forKey: "isCopied") == eqImage //the low quality image is copied to clipboard if required
            {
                let obj: NSObject = NSArray (object: NSImage(data: cpydata!)!)
                clipboard.clearContents()
                clipboard.writeObjects (obj as! [AnyObject] as! [NSPasteboardWriting])
            }
        }
        
    }

    
    
    override func viewDidLoad() //executed when view is loaded for the first time
    {
        
        super.viewDidLoad()
        
        box.becomeFirstResponder() //sets focus to box
        self.shortcutView.associatedUserDefaultsKey = "GlobalShortcut"; //tells the program to listen for the shortcut stored at key "GlobalShortcut"
        
        defaults.synchronize() //loads defaults from disk
        if defaults.object(forKey: "isCopied") == nil //this key tells whether the image or the latex code is copied to clipboard
        {
            defaults.set(eqImage, forKey: "isCopied") //the key is generated if not existing
            defaults.synchronize()
        }
        else if defaults.bool(forKey: "isCopied") == latexCode
        {
            stgsButton1.title = "latex code"
        }
        
        if defaults.object(forKey: "imgSize") == nil //this key tells the size of the displayed image
        {
            defaults.set(900, forKey: "imgSize") //the key is generated if not existing
            defaults.synchronize()
            stgsPopup1.selectItem(at: 2) //selects correct object in the settings' popup list
        }
            
        else {
            stgsPopup1.selectItem(at: defaults.integer(forKey: "imgSize")/300 - 1) //selects correct object in the settings' popup list
        }
        
    }
    
}




extension PanelViewController {
    
    
    @IBAction func updateImage (_ sender: NSTextField) //run when user presses enter
    
    {
        
        //box content is loaded as a string
        var proeq: String
        proeq = box.stringValue
        
        //latex code is copied to clipboard if necessary
        if defaults.bool(forKey: "isCopied") == latexCode {
            clipboard.clearContents()
            clipboard.setString(proeq, forType: NSStringPboardType)
        }
        
        proeq = proeq.replacingOccurrences(of: " ", with: "&space;", options: NSString.CompareOptions.literal, range: nil) //replaces spaces with string
        
        loadURL(proeq) //displays URL containing image
        
    }
    
    
    @IBAction func openSettings (_ sender: NSButton) //called when settings button is pressed; hides or displays main view/settings view
    
    {
        if !settings {
            mainView.isHidden = !mainView.isHidden
            settingsView.isHidden = !settingsView.isHidden
        }
        else {
            settingsView.isHidden = !settingsView.isHidden
            mainView.isHidden = !mainView.isHidden
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
    
    
    @IBAction func setImageSize (_ sender: NSPopUpButton) //called on edit of the popup button in the settings view
        
    {
        switch stgsPopup1.indexOfSelectedItem //assigns value to defaults key "imgsize" depending on user's choice
        {
        case 0:
            defaults.set(300, forKey: "imgSize")
        case 1:
            defaults.set(600, forKey: "imgSize")
        case 2:
            defaults.set(900, forKey: "imgSize")
        default:
            defaults.set(900, forKey: "imgSize")
            stgsPopup1.selectItem(at: 2)
        }
        defaults.synchronize()
    }
    
    
    @IBAction func switchCopyMode (_ sender: NSButton) //called on click on stgsbutton1
    
    {
        
        //defaults key "isCopied" is assigned its opposite value
        let boolToBeReverted: Bool = defaults.bool (forKey: "isCopied")
        defaults.set(!boolToBeReverted, forKey: "isCopied")
        defaults.synchronize()
        
        //adjusts stgsbutton1's title
        if !boolToBeReverted {
            stgsButton1.title = "equation"
        }
        else {
            stgsButton1.title = "latex code"
        }
    }
    
    
    @IBAction func quit (_ sender: NSButton) {
        NSApplication.shared().terminate(sender)
    }
    
}
