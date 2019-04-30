//
//  ViewController.swift
//  AssetGenerator
//
//  Created by Andrey on 11/03/2019.
//  Copyright © 2019 anddrrek. All rights reserved.
//

import Cocoa

final class ViewController: NSViewController {
     
    @IBOutlet private weak var selectedPathTextField: NSTextField!
    @IBOutlet private weak var resultPathTextField: NSTextField!
    
    private var selectedFolderPath: URL?
    private var resultPath: URL?

    //MARK: Actions
    @IBAction private func selectAsset(_ sender: NSButton) {
        showPanel { [weak self] url in
            guard let result = url else { return } // Pathname of the input file
            self?.selectedPathTextField.stringValue = result.path
            self?.selectedFolderPath = result
        }
    }
    
    @IBAction private func selectResult(_ sender: NSButton) {
        showPanel { [weak self] url in
            guard let result = url else { return } // Pathname of the result file
            self?.resultPathTextField.stringValue = result.path
            self?.resultPath = result
        }
    }
    
    @IBAction private func generateFile(_ sender: NSButton) {
        guard let sourceURL = selectedFolderPath,
            let resultURL = resultPath,
            let cases = FolderContentHelper.shared.getAllAssetNames(at: sourceURL) else {
                return
        }
        FileCreator.shared.createFile(at: resultURL, content: cases) { error in
            let alert = NSAlert()
            alert.messageText = error?.localizedDescription ?? "Success"
            alert.runModal()
        }
    }
    
    private func showPanel(completion: @escaping (URL?)->Void) {
        let dialog = NSOpenPanel()
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = false
        dialog.showsHiddenFiles = false
        dialog.showsTagField = true
        dialog.allowsMultipleSelection = false
        
        switch dialog.runModal() {
        case .OK:
            completion(dialog.url)
        default:
            return
        }
    }
}
