//
//  VerticalSplitViewController.swift
//  SingleFile
//
//  Created by David Littlefield on 7/28/19.
//  Copyright © 2019 David Littlefield. All rights reserved.
//

import Cocoa

/////////////////////////////////////////////////////////////////////////////////////////////

class VerticalSplitViewController: NSSplitViewController {
    
    // VIEW CONTROLLER //
    
    var horizontalSplitViewController: HorizontalSplitViewController?
    var webViewController: WebViewController?
    var saveViewController: SaveViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController() { [weak self] (complete) in
            self?.setupHorizontalSplitViewController()
            self?.setupWebViewController()
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension VerticalSplitViewController {
    
    // SETUP //

    private func setupViewController(completionHandler completion: @escaping (Bool) -> ()) {
        for viewController in children {
            switch viewController {
            case viewController as? HorizontalSplitViewController:
                horizontalSplitViewController = viewController as? HorizontalSplitViewController
            case viewController as? WebViewController:
                webViewController = viewController as? WebViewController
            default:
                break
            }
        }
        completion(true)
    }
    
    private func setupHorizontalSplitViewController() {
        horizontalSplitViewController?.webViewController = webViewController
        horizontalSplitViewController?.setupViewController()
        if let horizontalSplitViewController = horizontalSplitViewController {
            for viewController in horizontalSplitViewController.children {
                switch viewController {
                case viewController as? SaveViewController:
                    saveViewController = viewController as? SaveViewController
                default:
                    break
                }
            }
        }
    }
    
    private func setupWebViewController() {
        webViewController?.saveViewController = saveViewController
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////
