//
//  AppDelegate.swift
//  iP Status
//
//  Created by Harrison Milbradt on 2018-03-21.
//  Copyright © 2018 Harrison Milbradt. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var item : NSStatusItem? = nil
    let noInternetTitle = "...."
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item?.title = noInternetTitle
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Copy", action: #selector(copyToClipboard), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(refresh), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApplication), keyEquivalent: ""))
        
        item?.menu = menu
        
        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
    }
    
    @objc func refresh() {
        
        let ip = getWiFiAddress()
        
        if ip != nil && ip!.count > 1 {
            item?.title = ip
        } else {
            item?.title = noInternetTitle
        }
    }
    
    @objc func copyToClipboard() {
        
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.writeObjects([getWiFiAddress()! as NSString])
    }
    
    @objc func quitApplication() {
        NSApplication.shared.terminate(self)
    }
    
    // Return IP address of WiFi interface (en0) as a String, or `nil`
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
}

