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
    
    
    
    var eventMonitor: EventMonitor? //declares eventmonitor object that checks wether user clicks outside the application window - launched later
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2) //declares status bar object
    let popover = NSPopover.alloc() //declares popover object
    
    
    
    func applicationDidFinishLaunching(aNotification: NSNotification) //run when app gets opened
    
    {
        if let button = statusItem.button //initialises status item button
        {
            button.title = "ēq"
            button.action = Selector("togglePopover:")
            
            //event monitor is initialised
            eventMonitor = EventMonitor(mask: .LeftMouseDownMask | .RightMouseDownMask)
                { [unowned self] event in
                if self.popover.shown {
                    self.closePopover(event)
                }
            }
            eventMonitor?.start()
            
            //shortcut monitor is initialised
            MASShortcutBinder.sharedBinder().bindShortcutWithDefaultsKey("GlobalShortcut", toAction: { () -> Void in
                self.togglePopover (self)
            })
        }
        
        //popover is initialised
        popover.contentViewController = PanelViewController(nibName: "PanelViewController", bundle: nil)
    }

    
    
    func applicationWillTerminate(aNotification: NSNotification) {
        //ain't nobody got time for that
    }
    
    
    
    //the following funcions either show or hide the popover; note that when the popover gets shown, an event monitor is started (also, it is closed when popover gets hidden)
    
    func showPopover(sender: AnyObject?) {
        if let button = statusItem.button {
            popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge:NSMinYEdge)
            eventMonitor?.start()
            NSApp.activateIgnoringOtherApps(true)
        }
    }
    
    func closePopover (sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    func togglePopover (sender: AnyObject?) //this is the function that is actually called when the menuitem is pressed
    {
        if popover.shown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }

}

