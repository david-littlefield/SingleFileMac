//
//  OptionsViewController.swift
//  SingleFile
//
//  Created by David Littlefield on 7/27/19.
//  Copyright © 2019 David Littlefield. All rights reserved.
//

import Cocoa
import Foundation

/////////////////////////////////////////////////////////////////////////////////////////////

class OptionsViewController: NSViewController {

    // VIEW CONTROLLER //
    
    @IBOutlet weak var optionsTextField: NSTextField!
    @IBOutlet weak var saveOptionsButton: NSButton!
    @IBOutlet weak var resetOptionsButton: NSButton!
    
    var fileViewController: FileViewController?
    
    var defaults: UserDefaults?
    var fileManager: FileManager?
    var requiredFiles: [String]?
    var options: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
    }
    
    @IBAction func saveOptionsButtonClicked(_ sender: Any) {
        saveOptions()
    }
    
    @IBAction func resetOptionsButtonClicked(_ sender: Any) {
        resetOptions()
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension OptionsViewController {

    // SETUP //
    
    private func setupViewController() {
        setupTextField()
        setupButtons()
        setupDefaultSettings()
        setupOptions()
        setupFileManager()
        setupRequiredFiles()
        updateButtons()
    }
    
    private func setupTextField() {
        optionsTextField.delegate = self
        let string = "SingleFile \"Options\""
        var attributes: Dictionary<NSAttributedString.Key, Any> = [:]
        attributes[NSAttributedString.Key.foregroundColor] = NSColor.secondaryLabelColor
        attributes[NSAttributedString.Key.font] = NSFont(name: "Arial", size: 15.0)!
        optionsTextField.placeholderAttributedString = NSAttributedString(string: string, attributes: attributes)
        optionsTextField.wantsLayer = true
    }
    
    private func setupButtons() {
        saveOptionsButton.isEnabled = false
        resetOptionsButton.isEnabled = false
    }
    
    private func setupDefaultSettings() {
        defaults = UserDefaults.standard
    }
    
    private func setupOptions() {
        let customOptions = defaults?.string(forKey: "customOptions")
        let defaultOptions = defaults?.string(forKey: "defaultOptions")
        options = customOptions ?? defaultOptions
    }
    
    private func setupFileManager() {
        fileManager = FileManager.default
    }
    
    private func setupRequiredFiles() {
        requiredFiles = ["singlefile.js", "options.js", "library.js"]
    }
    
    func loadOptionsFromFile() {
        hasRequiredFiles { [weak self] (isTrue) in
            if isTrue {
                let defaultOptions = self?.defaults?.string(forKey: "defaultOptions")
                let customOptions = self?.defaults?.string(forKey: "customOptions")
                self?.options = customOptions ?? defaultOptions
                if let options = self?.options {
                    let optionsStart = "var options = { "
                    let optionsEnd = " }"
                    var string = options.replacingOccurrences(of: optionsStart, with: "")
                    string = string.replacingOccurrences(of: optionsEnd, with: "")
                    self?.optionsTextField.stringValue = string
                    self?.optionsTextField.isEditable = true
                    self?.optionsTextField.resignFirstResponder()
                    self?.updateButtons()
                } else {
                    self?.optionsTextField.stringValue = ""
                    self?.optionsTextField.isEditable = false
                    self?.updateButtons()
                }
            }
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension OptionsViewController: NSTextFieldDelegate, NSControlTextEditingDelegate {
    
    // TEXTFIELD //
    
    func controlTextDidChange(_ obj: Notification) {
        updateButtons()
    }
    
    func updateButtons() {
        hasRequiredFiles { [weak self] (isTrue) in
            if isTrue { 
                let optionsStart = "var options = { "
                let optionsEnd = " }"
                var defaultOptions = self?.defaults?.string(forKey: "defaultOptions")
                defaultOptions = defaultOptions?.replacingOccurrences(of: optionsStart, with: "")
                defaultOptions = defaultOptions?.replacingOccurrences(of: optionsEnd, with: "")
                var options = self?.options
                options = options?.replacingOccurrences(of: optionsStart, with: "")
                options = options?.replacingOccurrences(of: optionsEnd, with: "")
                let currentText = self?.optionsTextField?.stringValue
                if currentText != options {
                    self?.saveOptionsButton.isEnabled = true
                } else {
                    self?.saveOptionsButton.isEnabled = false
                }
                if options != defaultOptions {
                    self?.resetOptionsButton.isEnabled = true
                } else {
                    self?.resetOptionsButton.isEnabled = false
                }
            }
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension OptionsViewController {
    
    // OPTIONS //
    
    private func saveOptions() {
        if let inputFolderPath = defaults?.url(forKey: "inputFolderPath") {
            let optionsStart = "var options = { "
            let optionsEnd = " }"
            let optionsPath = inputFolderPath.appendingPathComponent("options.js")
            var options = optionsTextField.stringValue
            options = optionsStart + options + optionsEnd
            try? options.write(to: optionsPath, atomically: true, encoding: .utf8)
            defaults?.set(options, forKey: "customOptions")
            self.options = options
            updateButtons()
        }
    }
    
    private func resetOptions() {
        if let inputFolderPath = defaults?.url(forKey: "inputFolderPath"),
            var options = defaults?.string(forKey: "defaultOptions") {
            let optionsStart = "var options = { "
            let optionsEnd = " }"
            let optionsPath = inputFolderPath.appendingPathComponent("options.js")
            try? options.write(to: optionsPath, atomically: true, encoding: .utf8)
            defaults?.set(nil, forKey: "customOptions")
            self.options = options
            options = options.replacingOccurrences(of: optionsStart, with: "")
            options = options.replacingOccurrences(of: optionsEnd, with: "")
            optionsTextField.stringValue = options
            updateButtons()
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////

extension OptionsViewController {
    
    // FILES //
    
    func hasRequiredFiles(completionHandler completion: @escaping (Bool) -> ()) {
        if let fileViewController = fileViewController,
            let inputFolderPath = fileViewController.inputFolderPath,
            let requiredFiles = requiredFiles {
            let files = try? fileManager?.contentsOfDirectory(atPath: inputFolderPath.path)
            let hasRequiredFiles = files?.filter({ requiredFiles.contains($0) }).count == 3
            if hasRequiredFiles {
                completion(true)
            } else {
                completion(false)
            }
        } else {
            optionsTextField.stringValue = ""
            optionsTextField.isEditable = false
        }
    }
}
/////////////////////////////////////////////////////////////////////////////////////////////
