//
//  HorizontalSplitViewController.swift
//  SingleFile
//
//  Created by David Littlefield on 7/28/19.
//  Copyright © 2019 David Littlefield. All rights reserved.
//

import Cocoa

/////////////////////////////////////////////////////////////////////////////////////////////

class HorizontalSplitViewController: NSViewController {

    // VIEW CONTROLLER //
    
    var fileViewController: FileViewController?
    var optionsViewController: OptionsViewController?
    var saveViewController: SaveViewController?
    var webViewController: WebViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension HorizontalSplitViewController {
    
    // SETUP //
    
    func setupViewController() {
        setupViewControllers() { [weak self] (complete) in
            self?.setupFileViewController()
            self?.setupOptionsViewController()
            self?.setupSaveViewController()
        }
    }
    
    private func setupViewControllers(completionHandler completion: @escaping (Bool) -> ()) {
        if children.count > 0 {
            for viewController in children {
                switch viewController {
                case viewController as? FileViewController:
                    fileViewController = viewController as? FileViewController
                case viewController as? OptionsViewController:
                    optionsViewController = viewController as? OptionsViewController
                case viewController as? SaveViewController:
                    saveViewController = viewController as? SaveViewController
                default:
                    break
                }
            }
        }
        completion(true)
    }
    
    private func setupFileViewController() {
        fileViewController?.optionsViewController = optionsViewController
        fileViewController?.saveViewController = saveViewController
    }
    
    private func setupOptionsViewController() {
        optionsViewController?.fileViewController = fileViewController
        optionsViewController?.loadOptionsFromFile()
    }
    
    private func setupSaveViewController() {
        saveViewController?.webViewController = webViewController
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////
