//
//  FileViewController.swift
//  SingleFile
//
//  Created by David Littlefield on 7/26/19.
//  Copyright © 2019 David Littlefield. All rights reserved.
//

import Cocoa
import Foundation

/////////////////////////////////////////////////////////////////////////////////////////////

class FileViewController: NSViewController {
    
    // VIEW CONTROLLER //
    
    @IBOutlet weak var selectInputFolderButton: NSButton!
    @IBOutlet weak var changeOutputFolderButton: NSButton!
    @IBOutlet weak var selectInputFolderTextField: NSTextField!
    @IBOutlet weak var changeOutputFolderTextField: NSTextField!
    @IBOutlet weak var convertInputToOutputButton: NSButton!
    
    var optionsViewController: OptionsViewController?
    var saveViewController: SaveViewController?
    
    var defaults: UserDefaults?
    var fileManager: FileManager?
    var filePaths: [String]?
    var folderContent: [String]?
    var openPanel: NSOpenPanel?
    var inputFolderPath: URL?
    var outputFolderPath: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
    }
    
    @IBAction func selectSingleFileButtonClicked(_ sender: Any) {
        selectInputFolderPath()
    }
    
    @IBAction func selectHtmlOutputButtonClicked(_ sender: Any) {
        selectOutputFolderPath()
    }
    
    @IBAction func convertSingleFileToSwiftButtonClicked(_ sender: Any) {
        convertSingleFile()
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension FileViewController {
    
    // SETUP //
    
    private func setupViewController() {
        setupTextFields()
        setupDefaultSettings()
        setupFileManager()
        setupSupportingFilePaths()
        setupFolderContent()
        setupOpenPanel()
        setupUserInterface()
    }
    
    private func setupTextFields() {
        selectInputFolderTextField.placeholderAttributedString = NSAttributedString(string: "SingleFile-master", attributes: [NSAttributedString.Key.foregroundColor: NSColor.secondaryLabelColor, NSAttributedString.Key.font: NSFont(name: "Arial", size: 15.0)!])
        selectInputFolderTextField.wantsLayer = true
        changeOutputFolderTextField.placeholderAttributedString = NSAttributedString(string: "Html Download Folder", attributes: [NSAttributedString.Key.foregroundColor: NSColor.secondaryLabelColor, NSAttributedString.Key.font: NSFont(name: "Arial", size: 15.0)!])
        changeOutputFolderTextField.wantsLayer = true
    }
    
    private func setupDefaultSettings() {
        defaults = UserDefaults.standard
        inputFolderPath = defaults?.url(forKey: "inputFolderPath")
        outputFolderPath = defaults?.url(forKey: "outputFolderPath")
        if let inputFolderPath = inputFolderPath?.path {
            selectInputFolderTextField.stringValue = inputFolderPath
        }
        if let outputFolderPath = outputFolderPath?.path {
            changeOutputFolderTextField.stringValue = outputFolderPath
        }
    }
    
    private func setupFileManager() {
        fileManager = FileManager.default
    }
    
    private func setupSupportingFilePaths() {
        filePaths = [
            "index.js",
            "lib/hooks/content/content-hooks-web.js",
            "lib/hooks/content/content-hooks.js",
            "lib/hooks/content/content-hooks-frames-web.js",
            "lib/hooks/content/content-hooks-frames.js",
            "lib/fetch/content/content-fetch-resources.js",
            "lib/frame-tree/content/content-frame-tree.js",
            "lib/lazy/content/content-lazy-loader.js",
            "lib/single-file/single-file-util.js",
            "lib/single-file/single-file-helper.js",
            "lib/single-file/vendor/css-tree.js",
            "lib/single-file/vendor/html-srcset-parser.js",
            "lib/single-file/vendor/css-minifier.js",
            "lib/single-file/vendor/css-font-property-parser.js",
            "lib/single-file/vendor/css-media-query-parser.js",
            "lib/single-file/modules/html-minifier.js",
            "lib/single-file/modules/css-fonts-minifier.js",
            "lib/single-file/modules/css-fonts-alt-minifier.js",
            "lib/single-file/modules/css-matched-rules.js",
            "lib/single-file/modules/css-medias-alt-minifier.js",
            "lib/single-file/modules/css-rules-minifier.js",
            "lib/single-file/modules/html-images-alt-minifier.js",
            "lib/single-file/modules/html-serializer.js",
            "lib/single-file/single-file-core.js",
            "lib/single-file/single-file.js"
        ]
    }
    
    private func setupFolderContent() {
        folderContent = [
            "demo",
            "extension",
            "LICENSE",
            "privacy.md",
            "faq.md",
            "index.js",
            "cli",
            "README.MD",
            ".gitignore",
            ".github",
            "manifest.json",
            ".eslintrc.js",
            "lib",
            "_locales",
            "build-extension.sh"
        ]
    }
    
    private func setupOpenPanel() {
        openPanel = NSOpenPanel()
        openPanel?.allowsMultipleSelection = false
        openPanel?.canChooseDirectories = true
        openPanel?.canChooseFiles = false
        openPanel?.canCreateDirectories = false
        openPanel?.canResolveUbiquitousConflicts = false
        openPanel?.canDownloadUbiquitousContents = false
    }
    
    private func setupUserInterface() {
        if selectInputFolderTextField.stringValue != "" {
            selectInputFolderButton.isEnabled = true
            selectInputFolderTextField.isSelectable = true
            changeOutputFolderButton.isEnabled = true
            changeOutputFolderTextField.isSelectable = true
            selectInputFolderButton.resignFirstResponder()
            selectInputFolderButton.window?.makeFirstResponder(nil)
        } else {
            changeOutputFolderTextField.stringValue = ""
            selectInputFolderButton.isEnabled = true
            changeOutputFolderButton.isEnabled = false
        }
        hasContents { [weak self] (isTrue) in
            self?.convertInputToOutputButton.isEnabled = isTrue ? true : false
        }
    }
    
    private func hasContents(completionHandler completion: @escaping (Bool) -> ()) {
        if let inputFolderPath = inputFolderPath,
            let requiredFiles = folderContent,
            let files = try? fileManager?.contentsOfDirectory(atPath: inputFolderPath.path) {
            let hasRequiredFiles = files.filter({ requiredFiles.contains($0) }).count == requiredFiles.count
            if hasRequiredFiles {
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

extension FileViewController {
    
    // INTERFACE //
    
    private func resetUserInterface() {
        convertInputToOutputButton.isEnabled = false
        selectInputFolderButton.resignFirstResponder()
        changeOutputFolderButton.resignFirstResponder()
    }
    
    private func resetInputFolderPathTextField() {
        defaults?.set(nil, forKey: "inputFolderPath")
        selectInputFolderTextField.stringValue = ""
        inputFolderPath = nil
        setupUserInterface()
        saveViewController?.setupButtons()
    }
    
    func resetOutputFolderPathTextField() {
        defaults?.set(nil, forKey: "outputFolderPath")
        changeOutputFolderTextField.stringValue = ""
        outputFolderPath = nil
        setupUserInterface()
        saveViewController?.setupButtons()
    }
    
    func setupInputFolderPathTextField() {
        let inputFolderPath = openPanel?.urls[0]
        defaults?.set(inputFolderPath, forKey: "inputFolderPath")
        self.inputFolderPath = inputFolderPath
        selectInputFolderTextField.stringValue = inputFolderPath?.path ?? ""
        selectInputFolderTextField.resignFirstResponder()
        changeOutputFolderTextField.resignFirstResponder()
        selectInputFolderButton.resignFirstResponder()
        selectInputFolderButton.window?.makeFirstResponder(nil)
        saveViewController?.setupButtons()
    }
    
    private func setupDefaultOutputFolderPathTextField() {
        defaults?.set(inputFolderPath, forKey: "outputFolderPath")
        outputFolderPath = inputFolderPath
        changeOutputFolderTextField.stringValue = outputFolderPath?.path ?? ""
        changeOutputFolderTextField.resignFirstResponder()
        changeOutputFolderButton.isEnabled = true
        setupUserInterface()
        saveViewController?.setupButtons()
    }
    
    func setupOutputFolderPathTextField() {
        let outputFolderPath = openPanel?.urls[0]
        defaults?.set(outputFolderPath, forKey: "outputFolderPath")
        self.outputFolderPath = outputFolderPath
        changeOutputFolderTextField.stringValue = outputFolderPath?.path ?? ""
        changeOutputFolderTextField.resignFirstResponder()
        saveViewController?.setupButtons()
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension FileViewController {
    
    //  SELECT //
    
    private func selectInputFolderPath() {
        openPanel?.directoryURL = defaults?.url(forKey: "inputFolderPath")
        if let result = openPanel?.runModal(),
            result == .cancel {
            resetInputFolderPathTextField()
            optionsViewController?.loadOptionsFromFile()
        } else {
            setupInputFolderPathTextField()
            setupDefaultOutputFolderPathTextField()
            optionsViewController?.loadOptionsFromFile()
        }
    }
    
    private func selectOutputFolderPath() {
        openPanel?.directoryURL = defaults?.url(forKey: "outputFolderPath")
        if let result = openPanel?.runModal(),
            result == .cancel {
            resetInputFolderPathTextField()
            resetOutputFolderPathTextField()
            optionsViewController?.loadOptionsFromFile()
        } else {
            setupOutputFolderPathTextField()
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension FileViewController {
    
    // DELETE //
    
    private func deleteFolderContents() {
        if let inputFolderPath = inputFolderPath,
            inputFolderPath.lastPathComponent.lowercased().contains("singlefile-master"),
            let folderContent = folderContent {
            var files = try? fileManager?.contentsOfDirectory(at: inputFolderPath, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
            files = files?.filter({ folderContent.contains($0.lastPathComponent) })
            let _ = files?.compactMap({
                try? fileManager?.removeItem(at: $0)
            })
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension FileViewController {
    
    // CONVERT //
    
    private func convertSingleFile() {
        convertSupportingFiles()
        convertConfigFile()
        convertPuppeteerFile()
        deleteFolderContents()
        resetUserInterface()
        optionsViewController?.loadOptionsFromFile()
        optionsViewController?.updateButtons()
        saveViewController?.setupButtons()
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension FileViewController {
    
    // JAVASCRIPT //
    
    private func saveJavaScriptFile(asFileName fileName: String, fromString string: String) {
        if let inputFolderPath = inputFolderPath {
            let filePath = inputFolderPath.appendingPathComponent(fileName)
            try? string.write(to: filePath, atomically: true, encoding: .utf8)
        }
    }
    
    private func replace(javaScript: String, withJavaScript: String, inPath: String) {
        if let filePath = inputFolderPath?.appendingPathComponent(inPath),
            var string = try? String(contentsOf: filePath),
            string.contains(javaScript) {
            string = string.replacingOccurrences(of: javaScript, with: withJavaScript)
            try? string.write(to: filePath, atomically: true, encoding: .utf8)
        }
    }
    
    func replace(javaScript: String, withJavaScript: String, fromJavaScript: String, inPath: String) {
        if let inputFolderPath = inputFolderPath {
            let path = inputFolderPath.appendingPathComponent(inPath)
            let contents = try? String(contentsOf: path, encoding: .utf8)
            var components = format(javaScript: contents ?? "")
            let javaScript = format(javaScript: javaScript)
            for component in javaScript {
                if let index = components.firstIndex(of: component) {
                    components.remove(at: index)
                    components.insert(withJavaScript, at: index)
                }
            }
            let string = components.joined(separator: "\n")
            try? string.write(to: path, atomically: true, encoding: .utf8)
        }
    }
    
    func format(javaScript: String) -> [String] {
        var components = javaScript.components(separatedBy: "\n")
        components = components.compactMap({ $0.trimmingCharacters(in: .whitespacesAndNewlines)})
        return components
    }
    
    private func insert(javaScript: String, beforeJavaScript: String, inPath: String) {
        if let inputFolderPath = inputFolderPath {
            let path = inputFolderPath.appendingPathComponent(inPath)
            let contents = try? String(contentsOf: path, encoding: .utf8)
            var components = format(javaScript: contents ?? "")
            let javaScript = format(javaScript: beforeJavaScript)
            for component in javaScript {
                if let index = components.firstIndex(of: beforeJavaScript) {
                    components.insert(component, at: index)
                }
            }
            let string = components.joined(separator: "\n")
            try? string.write(to: path, atomically: true, encoding: .utf8)
        }
    }
    
    private func insert(javaScript: String, afterJavaScript: String, inPath: String) {
        if let inputFolderPath = inputFolderPath {
            let path = inputFolderPath.appendingPathComponent(inPath)
            let contents = try? String(contentsOf: path, encoding: .utf8)
            var components = format(javaScript: contents ?? "")
            let javaScript = format(javaScript: javaScript)
            for component in javaScript {
                if let index = components.firstIndex(of: afterJavaScript) {
                    components.insert(component, at: index + 1)
                }
            }
            let string = components.joined(separator: "\n")
            try? string.write(to: path, atomically: true, encoding: .utf8)
        }
    }
    
    private func insertAtEnd(javaScript: String, inPath: String) {
        if let inputFolderPath = inputFolderPath {
            let path = inputFolderPath.appendingPathComponent(inPath)
            let contents = try? String(contentsOf: path, encoding: .utf8)
            var components = format(javaScript: contents ?? "")
            let javaScript = format(javaScript: javaScript)
            for component in javaScript {
                let index = components.endIndex
                components.insert(component, at: index)
            }
            let string = components.joined(separator: "\n")
            try? string.write(to: path, atomically: true, encoding: .utf8)
        }
    }
    
    private func trim(javaScript: String, fromStart: Bool, toEnd: Bool, inPath: String) {
        if let path = inputFolderPath?.appendingPathComponent(inPath),
            let string = try? String(contentsOf: path),
            string.contains(javaScript) {
            if let startIndex = string.range(of: javaScript)?.lowerBound,
                fromStart {
                let string = string[startIndex ..< string.endIndex]
                try? string.write(to: path, atomically: true, encoding: .utf8)
            }
            if let endIndex = string.range(of: javaScript)?.upperBound,
                toEnd {
                let string = string[string.startIndex ..< endIndex]
                try? string.write(to: path, atomically: true, encoding: .utf8)
            }
        }
    }
    
    private func removeNewLines(inPath: String) {
        if let path = inputFolderPath?.appendingPathComponent(inPath),
            var string = try? String(contentsOf: path) {
            string = string.replacingOccurrences(of: "\n\n\n\n", with: "\n")
            string = string.replacingOccurrences(of: "\n\n\n", with: "\n")
            string = string.replacingOccurrences(of: "\n\n", with: "\n")
            try? string.write(to: path, atomically: true, encoding: .utf8)
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension FileViewController {
    
    // OPTIONS //
    
    private func convertConfigFile() {
        let path = "extension/core/bg/config.js"
        let defaultConfigStart = "const DEFAULT_CONFIG = {"
        let defaultConfigEnd = "};"
        let optionsStart = "var options = { "
        let optionsEnd = " }"
        trim(javaScript: defaultConfigStart, fromStart: true, toEnd: false, inPath: path)
        trim(javaScript: defaultConfigEnd, fromStart: false, toEnd: true, inPath: path)
        replace(javaScript: defaultConfigStart, withJavaScript: "", inPath: path)
        replace(javaScript: defaultConfigEnd, withJavaScript: "", inPath: path)
        if let filePath = outputFolderPath?.appendingPathComponent(path),
            let string = try? String(contentsOf: filePath, encoding: .utf8) {
            var components = string.components(separatedBy: ",")
            components = components.compactMap({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            var string = components.joined(separator: ",\n")
            string = optionsStart + string + optionsEnd
            defaults?.set(string, forKey: "defaultOptions")
            defaults?.set(nil, forKey: "customOptions")
            let fileName = "options.js"
            saveJavaScriptFile(asFileName: fileName, fromString: string)
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension FileViewController {
    
    // SINGLEFILE //
    
    private func convertPuppeteerFile() {
        let path = "cli/back-ends/puppeteer.js"
        let evaluateStart = "return await page.evaluate(async options => {"
        let evaluateEnd = "}, options);"
        let getPageData = "return await singleFile.getPageData();"
        let htmlContent = "var html = (await singleFile.getPageData()).content;"
        let runStart = "async function runSingleFile() {"
        let runEnd = "webkit.messageHandlers.websiteHasBeenSaved.postMessage(html);\n}"
        trim(javaScript: evaluateStart, fromStart: true, toEnd: false, inPath: path)
        trim(javaScript: evaluateEnd, fromStart: false, toEnd: true, inPath: path)
        replace(javaScript: getPageData, withJavaScript: htmlContent, inPath: path)
        replace(javaScript: evaluateStart, withJavaScript: runStart, inPath: path)
        replace(javaScript: evaluateEnd, withJavaScript: runEnd, inPath: path)
        if let filePath = outputFolderPath?.appendingPathComponent(path),
            let string = try? String(contentsOf: filePath, encoding: .utf8) {
            let fileName = "singlefile.js"
            saveJavaScriptFile(asFileName: fileName, fromString: string)
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension FileViewController {
    
    // LIBRARY //
    
    private func convertSupportingFiles() {
        if let paths = filePaths {
            convertContentHooksWebFile()
            convertContentHooksFile()
            convertContentHooksFramesWebFile()
            convertContentHooksFramesFile()
            convertContentFetchResourcesFile()
            convertIndexFile()
            convertOtherFiles()
            mergeJavaScriptFiles(fromPaths: paths)
        }
    }
    
    private func convertIndexFile() {
        if let path = filePaths?[0] {
            let thisSingleFile = "this.singlefile = this.singlefile || {"
            let varSingleFile = "var singlefile = {"
            replace(javaScript: thisSingleFile, withJavaScript: varSingleFile, inPath: path)
            removeNewLines(inPath: path)
        }
    }
    
    private func convertOtherFiles() {
        if let paths = filePaths {
            for index in 1 ..< paths.count {
                let path = paths[index]
                let thisSingleFile = "this.singlefile"
                let windowSingleFile = "window.singlefile"
                replace(javaScript: thisSingleFile, withJavaScript: windowSingleFile, inPath: path)
                removeNewLines(inPath: path)
            }
        }
    }
    
    private func convertContentHooksWebFile() {
        if let path = filePaths?[1] {
            let returnStart = "(() => {"
            let returnEnd = "})();"
            let varStart = "var contentHooksWeb = `"
            let varEnd = "`"
            replace(javaScript: returnStart, withJavaScript: varStart, inPath: path)
            replace(javaScript: returnEnd, withJavaScript: varEnd, inPath: path)
            removeNewLines(inPath: path)
        }
    }
    
    private func convertContentHooksFramesWebFile() {
        if let path = filePaths?[3] {
            let returnStart = "(() => {"
            let returnEnd = "})();"
            let varStart = "var contentHooksFramesWeb = `"
            let varEnd = "`"
            replace(javaScript:returnStart, withJavaScript: varStart, inPath: path)
            replace(javaScript: returnEnd, withJavaScript: varEnd, inPath: path)
            removeNewLines(inPath: path)
        }
    }

    private func convertContentHooksFile() {
        if let path = filePaths?[2] {
            let ifElseBlock = """
            if (this.browser && browser.runtime && browser.runtime.getURL) {
                scriptElement.src = browser.runtime.getURL("/lib/hooks/content/content-hooks-web.js");
                scriptElement.async = false;
            } else if (this.singlefile.lib.getFileContent) {
                scriptElement.textContent = this.singlefile.lib.getFileContent("/lib/hooks/content/content-hooks-web.js");
            }
            """
            let scriptElement = "scriptElement.async = false;"
            let textContent = "scriptElement.textContent = contentHooksWeb;"
            replace(javaScript: ifElseBlock, withJavaScript: textContent, fromJavaScript: scriptElement, inPath: path)
            removeNewLines(inPath: path)
        }
    }

    private func convertContentHooksFramesFile() {
        if let path = filePaths?[4] {
            let ifElseBlock = """
            if (this.browser && browser.runtime && browser.runtime.getURL) {
                scriptElement.src = browser.runtime.getURL("/lib/hooks/content/content-hooks-frames-web.js");
                scriptElement.async = false;
            } else if (this.singlefile.lib.getFileContent) {
                scriptElement.textContent = this.singlefile.lib.getFileContent("/lib/hooks/content/content-hooks-frames-web.js");
            }
            """
            let scriptElement = "let scriptElement = document.createElement(\"script\");"
            let textContent = "scriptElement.textContent = contentHooksFramesWeb;"
            replace(javaScript: ifElseBlock, withJavaScript: textContent, fromJavaScript: scriptElement, inPath: path)
            removeNewLines(inPath: path)
        }
    }
    
    private func convertContentFetchResourcesFile() {
        if let path = filePaths?[5] {
            let events = """
            const FETCH_REQUEST_EVENT = "single-file-request-fetch";
            const FETCH_RESPONSE_EVENT = "single-file-response-fetch";
            """
            let pending = "const pendingMessages = new Map();"
            let fetch = """
            this.singlefile.lib.fetch.content.resources = this.singlefile.lib.fetch.content.resources || (() => {
            """
            let response = "response = await hostFetch(url);"
            let nativeFetch = "return nativeFetch(url);"
            let error = "catch (error) {"
            let bracketEnd = "}"
            let bracketEndComma = "},"
            let callback = """
            callbackFetch: message => {
                const callbacks = pendingMessages.get(message.url);
                if (callbacks) {
                    pendingMessages.delete(message.url);
                    if (message.error) {
                        callbacks.forEach(callback => callback.reject(message.error));
                    } else {
                        const data = {
                            status: message.status,
                            headers: { get: name => message.headers[name] },
                            arrayBuffer: async () => new Uint8Array(message.body).buffer
                        };
                        callbacks.forEach(callback => callback.resolve(data));
                    }
                }
            }
            """
            let bracketEndSemicolon = "};"
            let function = """
            function nativeFetch(url) {
                return new Promise((resolve, reject) => {
                    webkit.messageHandlers.performHttpRequest.postMessage(url);
                    let callbacks = pendingMessages.get(url);
                    if (!callbacks) {
                        callbacks = [];
                        pendingMessages.set(url, callbacks);
                    }
                    callbacks.push({ resolve, reject });
                });
            }
            """
            let scriptEnd = "})();"
            replace(javaScript: events, withJavaScript: "", fromJavaScript: "", inPath: path)
            insert(javaScript: pending, afterJavaScript: fetch, inPath: path)
            replace(javaScript: response, withJavaScript: nativeFetch, inPath: path)
            trim(javaScript: error, fromStart: false, toEnd: true, inPath: path)
            insert(javaScript: nativeFetch, afterJavaScript: error, inPath: path)
            insertAtEnd(javaScript: bracketEnd, inPath: path)
            insertAtEnd(javaScript: bracketEndComma, inPath: path)
            insertAtEnd(javaScript: callback, inPath: path)
            insertAtEnd(javaScript: bracketEndSemicolon, inPath: path)
            insertAtEnd(javaScript: function, inPath: path)
            insertAtEnd(javaScript: scriptEnd, inPath: path)
            removeNewLines(inPath: path)
        }
    }
    
    private func mergeJavaScriptFiles(fromPaths paths: [String]) {
        var string = ""
        for index in 0 ..< paths.count {
            if let path = filePaths?[index],
                let url = inputFolderPath?.appendingPathComponent(path),
                let content = try? String(contentsOf: url) {
                string.append(contentsOf: content)
                string.append(contentsOf: "\n\n")
                if index == paths.count - 1 {
                    let fileName = "library.js"
                    saveJavaScriptFile(asFileName: fileName, fromString: string)
                }
            }
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////
