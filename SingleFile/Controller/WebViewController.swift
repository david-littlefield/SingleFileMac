//
//  WebViewController.swift
//  SingleFile
//
//  Created by David Littlefield on 7/24/19.
//  Copyright © 2019 David Littlefield. All rights reserved.
//

import Cocoa
import WebKit

/////////////////////////////////////////////////////////////////////////////////////////////

// VIEW CONTROLLER //

class WebViewController: NSViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var saveViewController: SaveViewController?
    
    var nsWindow: NSWindow?
    var fileManager: FileManager?
    var defaults: UserDefaults?
    var alert: NSAlert?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension WebViewController: NSAlertDelegate {
    
    // SETUP //
    
    private func setupViewController() {
        setupFileManager()
        setupDefaultSettings()
        setupUserContentController()
        setupWebViewDelegates()
        loadJavaScriptFiles()
        setupAlert()
    }
    
    private func setupFileManager() {
        fileManager = FileManager.default
    }
    
    private func setupDefaultSettings() {
        defaults = UserDefaults.standard
    }
    
    private func setupUserContentController() {
        let userContentController = webView.configuration.userContentController
        userContentController.removeScriptMessageHandler(forName: "websiteHasBeenSaved")
        userContentController.add(self, name: "websiteHasBeenSaved")
        userContentController.add(self, name: "performHttpRequest")
    }
    
    private func setupWebViewDelegates() {
        webView.navigationDelegate = self
        webView.uiDelegate = self
    }
    
    func loadJavaScriptFiles() {
        if let inputFolderPath = defaults?.url(forKey: "inputFolderPath") {
            let libraryPath = inputFolderPath.appendingPathComponent("library.js")
            let optionsPath = inputFolderPath.appendingPathComponent("options.js")
            let singlefilePath = inputFolderPath.appendingPathComponent("singlefile.js")
            if let singlefileSource = try? String(contentsOf: singlefilePath, encoding: .utf8),
                let librarySource = try? String(contentsOf: libraryPath, encoding: .utf8),
                let optionsSource = try? String(contentsOf: optionsPath, encoding: .utf8) {
                let libraryScript = WKUserScript(source: librarySource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
                let optionsScript = WKUserScript(source: optionsSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
                let singlefileScript = WKUserScript(source: singlefileSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                let userContentController = webView.configuration.userContentController
                userContentController.removeAllUserScripts()
                userContentController.addUserScript(libraryScript)
                userContentController.addUserScript(optionsScript)
                userContentController.addUserScript(singlefileScript)
            }
        }
    }
    
    private func setupAlert() {
        alert = NSAlert()
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension WebViewController {
    
    // INTERFACE //
    
    private func updateWindow(fromTitle title: String?, fromUrl url: URL?) {
        if let title = title,
            let url = url {
            DispatchQueue.main.async { [weak self] in
                self?.nsWindow?.title = title
                self?.saveViewController?.urlTextField.stringValue = url.absoluteString
            }
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        alert?.messageText = message
        alert?.runModal()
        completionHandler()
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension WebViewController {
    
    // SINGLEFILE //
    
    func runSingleFile() {
        let script = "runSingleFile();"
        webView.evaluateJavaScript(script)
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension WebViewController: WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
    
    // WEBKIT //
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "websiteHasBeenSaved":
            saveHtmlFileToLocalFolder(fromMessage: message)
        case "performHttpRequest":
            performHttpRequest(fromMessage: message)
        default:
            break
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        updateWindow(fromTitle: webView.title, fromUrl: webView.url)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView.title != "" {
            updateWindow(fromTitle: webView.title, fromUrl: webView.url)
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension WebViewController {
    
    // HTML //
    
    private func performHttpRequest(fromMessage message: WKScriptMessage) {
        if let message = message.body as? String,
            let url = URL(string: message) {
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                if error == nil {
                    let dictionary = self?.createDictionary(fromData: data, fromResponse: response)
                    let message = self?.encodeMessage(fromDictionary: dictionary)
                    let script = self?.createScript(fromMessage: message)
                    self?.evaluateJavaScript(fromScript: script)
                } else {
                    let dictionary = self?.createDictionary(fromError: error, fromResponse: response)
                    let message = self?.encodeMessage(fromDictionary: dictionary)
                    let script = self?.createScript(fromMessage: message)
                    self?.evaluateJavaScript(fromScript: script)
                }
            }
            task.resume()
        }
    }
        
    private func createDictionary(fromError error: Error?, fromResponse response: URLResponse?) -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let error = error,
            let url = response?.url {
            dictionary["url"] = url.absoluteString
            dictionary["error"] = error.localizedDescription
        }
        return dictionary
    }
        
    private func createDictionary(fromData data: Data?, fromResponse response: URLResponse?) -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let response = response as? HTTPURLResponse,
            let url = response.url,
            let data = data {
            let status = response.statusCode
            let body = data.map({ Int8(bitPattern: $0) })
            let headers = parseHeaderFields(fromResponse: response)
            dictionary["url"] = url.absoluteString
            dictionary["status"] = status.description
            dictionary["body"] = body
            dictionary["headers"] = headers
        }
        return dictionary
    }
    
    private func parseHeaderFields(fromResponse response: HTTPURLResponse) -> [String: Any] {
        var headers: [String: Any] = [:]
        var fields = response.allHeaderFields
        for key in fields.keys {
            if let key = key as? String {
                let value = fields[key]
                headers[key] = value
            }
        }
        return headers
    }
    
    private func encodeMessage(fromDictionary dictionary: [String: Any]?) -> String {
        var message = ""
        if let dictionary = dictionary,
            let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []),
            let string = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
            message = string
        }
        return message
    }
    
    private func createScript(fromMessage message: String?) -> String {
        var script = ""
        if let message = message {
            script =  "window.singlefile.lib.fetch.content.resources.callbackFetch(\(message))"
        }
        return script
    }
    
    private func evaluateJavaScript(fromScript script: String?) {
        if let script = script {
            DispatchQueue.main.async { [weak self] in
                self?.webView.evaluateJavaScript(script)
            }
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension WebViewController {
    
    // SAVE //
    
    private func saveHtmlFileToLocalFolder(fromMessage message: WKScriptMessage) {
        if let html = message.body as? String,
            let title = message.webView?.title,
            let outputFolderPath = defaults?.url(forKey: "outputFolderPath") {
            let filePath = outputFolderPath.appendingPathComponent("\(title).html")
            try? html.write(to: filePath, atomically: true, encoding: .utf8)
            saveViewController?.showProgressIndicator(false)
            saveViewController?.saveHtmlButton.isEnabled = true
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////
