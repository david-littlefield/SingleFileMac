//
//  SaveViewController.swift
//  SingleFile
//
//  Created by David Littlefield on 7/26/19.
//  Copyright © 2019 David Littlefield. All rights reserved.
//

import Cocoa
//import Alamofire

/////////////////////////////////////////////////////////////////////////////////////////////

class SaveViewController: NSViewController {
    
    // VIEW CONTROLLER //
    
    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet weak var scriptTextField: NSTextField!
    @IBOutlet weak var openUrlButton: NSButton!
    @IBOutlet weak var injectScriptButton: NSButton!
    @IBOutlet weak var saveHtmlButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    var webViewController: WebViewController?
    
    var defaults: UserDefaults?
    var fileManager: FileManager?
    var requiredFiles: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
    }
    
    @IBAction func openUrlButtonClicked(_ sender: Any) {
        openUrlInWebView()
    }
    
    @IBAction func injectScriptButtonClicked(_ sender: Any) {
        injectScriptIntoWebView()
    }
    
    @IBAction func saveHtmlButtonClicked(_ sender: Any) {
        saveHtmlInWebView()
    }
    
    @IBAction func urlTextFieldAction(_ sender: Any) {
        openUrlInWebView()
    }
    
    @IBAction func scriptTextFieldAction(_ sender: Any) {
        injectScriptIntoWebView()
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension SaveViewController {
    
    // SETUP //
    
    private func setupViewController() {
        setupTextFields()
        setupDefaultSettings()
        setupFileManager()
        setupRequiredFiles()
        setupButtons()
    }
    
    private func setupTextFields() {
        setupUrlTextField()
        setupScriptTextField()
    }
    
    private func setupUrlTextField() {
        let string = "Enter URL Here"
        var attributes: Dictionary<NSAttributedString.Key, Any> = [:]
        attributes[NSAttributedString.Key.foregroundColor] = NSColor.secondaryLabelColor
        attributes[NSAttributedString.Key.font] = NSFont(name: "Arial", size: 15.0)!
        urlTextField.placeholderAttributedString = NSAttributedString(string: string, attributes: attributes)
        urlTextField.wantsLayer = true
    }
    
    private func setupScriptTextField() {
        let string = "Enter \"Script\" Here"
        var attributes: Dictionary<NSAttributedString.Key, Any> = [:]
        attributes[NSAttributedString.Key.foregroundColor] = NSColor.secondaryLabelColor
        attributes[NSAttributedString.Key.font] = NSFont(name: "Arial", size: 15.0)!
        scriptTextField.placeholderAttributedString = NSAttributedString(string: string, attributes: attributes)
        scriptTextField.wantsLayer = true
    }
    
    private func setupDefaultSettings() {
        defaults = UserDefaults.standard
    }
    
    private func setupFileManager() {
        fileManager = FileManager.default
    }
    
    private func setupRequiredFiles() {
        requiredFiles = ["singlefile.js", "options.js", "library.js"]
    }
    
    func setupButtons() {
        hasContent { [weak self] (isTrue) in
            self?.openUrlButton.isEnabled = isTrue
            self?.injectScriptButton.isEnabled = isTrue
            self?.urlTextField.isEnabled = isTrue
            self?.urlTextField.isEditable = isTrue
            self?.scriptTextField.isEditable = isTrue
        }
    }
    
    private func hasContent(completionHandler completion: @escaping (Bool) -> ()) {
        if let path = defaults?.url(forKey: "inputFolderPath")?.path,
            let requiredFiles = requiredFiles,
            let files = try? fileManager?.contentsOfDirectory(atPath: path) {
            let hasContent = files.filter({ requiredFiles.contains($0) }).count == 3
            if hasContent {
                completion(true)
            } else {
                completion(false)
            }
        } else {
            completion(false)
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension SaveViewController {
    
    // INTERFACE //
    
    private func displayTextFieldBorder(_ show: Bool) {
        urlTextField.layer?.borderColor = NSColor.red.cgColor
        urlTextField.layer?.borderWidth = show ? 1.0 : 0.0
    }
    
    func showProgressIndicator(_ show: Bool) {
        if let progressIndicator = progressIndicator {
            progressIndicator.isHidden = !show
            show ? progressIndicator.startAnimation(nil) : progressIndicator.stopAnimation(nil)
        }
    }
    
    private func displayUrlResponseError() {
        DispatchQueue.main.async { [weak self] in
            self?.displayTextFieldBorder(true)
            self?.saveHtmlButton.isEnabled = false
            self?.showProgressIndicator(false)
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension SaveViewController {
    
    // WEBVIEW //
    
    private func openUrlInWebView() {
        displayTextFieldBorder(false)
        saveHtmlButton.isEnabled = false
        showProgressIndicator(true)
        var url = urlTextField.stringValue
        url = url.contains("://") ? url : "https://" + url
        urlTextField.stringValue = url
        if let url = URL(string: url) {
            performHttpRequest(fromUrl: url)
        }
    }
    
    private func performHttpRequest(fromUrl url: URL) {
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { [weak self] (_, response, error) in
            if let response = response as? HTTPURLResponse {
                self?.loadWebsite(forRequest: request, fromResponse: response)
            } else {
                self?.displayUrlResponseError()
            }
        }
        task.resume()
    }
    
    private func loadWebsite(forRequest request: URLRequest, fromResponse response: HTTPURLResponse) {
        DispatchQueue.main.async { [weak self] in
            switch response.statusCode {
            case 200:
                self?.webViewController?.webView.load(request)
                self?.saveHtmlButton.isEnabled = true
                self?.showProgressIndicator(false)
            default:
                self?.displayUrlResponseError()
            }
        }
    }
    
    private func injectScriptIntoWebView() {
        let script = scriptTextField.stringValue
        webViewController?.webView.evaluateJavaScript(script) { [weak self] (_, error) in
            if let error = error as? String {
                self?.webViewController?.alert?.messageText = error
                self?.webViewController?.alert?.runModal()
            }
        }
    }
    
    private func saveHtmlInWebView() {
        showProgressIndicator(true)
        saveHtmlButton.isEnabled = false
        webViewController?.runSingleFile()
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////
