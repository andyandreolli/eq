//
//  AppDelegate.swift
//  ēq
//
//  Created by Andrea Andreolli on 18/05/15.
//  Copyright (c) 2015 Andrea Andreolli. All rights reserved.
//

import Cocoa
import WebKit


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var eventMonitor: EventMonitor?
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    let popover = NSPopover.alloc ()
    var clipboard = NSPasteboard.generalPasteboard()
    var defaults = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var window: NSWindow!
    @IBOutlet var pic: NSImageView!
    @IBOutlet var box: NSTextField!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let button = statusItem.button {
            button.title = "ēq"
            button.action = Selector("togglePopover:")
            eventMonitor = EventMonitor(mask: .LeftMouseDownMask | .RightMouseDownMask) { [unowned self] event in
                if self.popover.shown {
                    self.closePopover(event)
                }
            }
            eventMonitor?.start()
        }
        box.becomeFirstResponder()
        
        defaults.synchronize() //get defaults and check their existence
        if defaults.objectForKey("eq.copyIMG") == nil {
            defaults.setBool(true, forKey: "eq.copyIMG")
            defaults.synchronize()
        }
        if defaults.objectForKey("eq.imgSize") == nil {
            defaults.setInteger(900, forKey: "eq.imgSize")
            defaults.synchronize()
        }
        popover.contentViewController = PanelViewController(nibName: "PanelViewController", bundle: nil)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge:NSMinYEdge)
            eventMonitor?.start()
        }
    }

    func closePopover (sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    func togglePopover (sender: AnyObject?) {
        if popover.shown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func loadURL (eq: String) {
        var req = "http://latex.codecogs.com/png.latex?\\dpi{" + String(defaults.integerForKey("eq.imgSize"))
        req = req + "}&space;{\\color{White}" + eq + "}"
        var cpy = "http://latex.codecogs.com/png.latex?\\dpi{200}&space;" + eq
        req = req.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
        cpy = cpy.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())!
        let requesturl = NSURL (string: req)
        let cpyurl = NSURL(string: cpy)
        let data = NSData(contentsOfURL: requesturl!)
        let cpydata = NSData(contentsOfURL: cpyurl!)
        if data != nil {
            pic.image = NSImage(data: data!)
            if defaults.boolForKey("eq.copyIMG") {
                var obj: NSObject = NSArray (object: NSImage(data: cpydata!)!)
                clipboard.clearContents()
                clipboard.writeObjects (obj as! [AnyObject])
            }
        }
    }

}

extension AppDelegate {
    
    @IBAction func updateImage (sender: NSTextField) {
        var proeq: String
        proeq = box.stringValue
        if !defaults.boolForKey("eq.copyIMG") {
            clipboard.clearContents()
            clipboard.setString(proeq, forType: NSStringPboardType)
        }
        proeq = proeq.stringByReplacingOccurrencesOfString(" ", withString: "&space;", options: NSStringCompareOptions.LiteralSearch, range: nil)
        loadURL(proeq)
    }

}

