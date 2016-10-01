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
    let statusItem = NSStatusBar.system().statusItem(withLength: -2) //declares status bar object
    let popover = NSPopover() //declares popover object
    
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) //run when app gets opened
    
    {
        if let button = statusItem.button //initialises status item button
        {
            button.title = "ēq"
            button.action = #selector(AppDelegate.togglePopover(_:))
            
            //event monitor is initialised
            eventMonitor = EventMonitor(mask: [.leftMouseDown , .rightMouseDown])
                { [unowned self] event in
                if self.popover.isShown {
                    self.closePopover(event)
                }
            }
            eventMonitor?.start()
            
            //shortcut monitor is initialised
            MASShortcutBinder.shared().bindShortcut(withDefaultsKey: "GlobalShortcut", toAction: { () -> Void in
                self.togglePopover (self)
            })
        }
        
        //popover is initialised
        popover.contentViewController = PanelViewController(nibName: "PanelViewController", bundle: nil)
    }

    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        //ain't nobody got time for that
    }
    
    
    
    //the following funcions either show or hide the popover; note that when the popover gets shown, an event monitor is started (also, it is closed when popover gets hidden)
    
    func showPopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge:NSRectEdge.minY)
            eventMonitor?.start()
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func closePopover (_ sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    func togglePopover (_ sender: AnyObject?) //this is the function that is actually called when the menuitem is pressed
    {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }

}

