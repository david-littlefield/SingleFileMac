//
//  WindowController.swift
//  SingleFile
//
//  Created by David Littlefield on 7/27/19.
//  Copyright © 2019 David Littlefield. All rights reserved.
//

import Cocoa

/////////////////////////////////////////////////////////////////////////////////////////////

class WindowController: NSWindowController {
    
    // WINDOW CONTROLLER //
    
    var horizontalSplitViewController: HorizontalSplitViewController?
    var webViewController: WebViewController?
    
    var alert: NSAlert?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        setupWindowController()
    }
    
    @IBAction func aboutMenuItemClicked(_ sender: Any) {
        displayAboutAlert()
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension WindowController {
    
    // SETUP //
    
    private func setupWindowController() {
        setupDarkAquaAppearance()
        setupHorizontalSplitViewController()
        setupAlert()
    }
    
    private func setupDarkAquaAppearance() {
        window?.appearance = NSAppearance(named: .darkAqua)
    }
    
    private func setupHorizontalSplitViewController() {
        if let verticalSplitViewController = window?.contentViewController {
            for viewController in verticalSplitViewController.children {
                switch viewController {
                case viewController as? HorizontalSplitViewController:
                    horizontalSplitViewController = viewController as? HorizontalSplitViewController
                case viewController as? WebViewController:
                    webViewController = viewController as? WebViewController
                    webViewController?.nsWindow = window
                default:
                    break
                }
            }
        }
    }
    
    private func setupAlert() {
        alert = NSAlert()
        let messageText = "SingleFile"
        let informativeText = """
        SingleFile is a Web Extension compatible with Chrome, Firefox (Desktop and Mobile), Chromium-based Edge, Vivaldi, Brave, Waterfox, Yandex browser, and Opera. It helps you to save a complete web page into a single HTML file.
        """
        let icon = Bundle.main.image(forResource: "Logo")
        alert?.window.title = "About"
        alert?.messageText = messageText
        alert?.informativeText = informativeText
        alert?.icon = icon
        alert?.addButton(withTitle: "OK")
        alert?.addButton(withTitle: "GitHub")
        alert?.buttons[1].refusesFirstResponder = true
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension WindowController: NSAlertDelegate {
    
    // INTERFACE //
    
    private func displayAboutAlert() {
        if let response = alert?.runModal() {
            handleButtonClicked(fromResponse: response)
        }
    }
    
    private func handleButtonClicked(fromResponse response: NSApplication.ModalResponse) {
        switch response {
        case .alertSecondButtonReturn:
            let string = "https://github.com/gildas-lormeau/SingleFile"
            if let url = URL(string: string){
                NSWorkspace.shared.open(url)
            }
        default:
            break
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////
