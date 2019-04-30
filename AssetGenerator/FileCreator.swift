//
//  FileCreator.swift
//  AssetGenerator
//
//  Created by Andrey on 12/04/2019.
//  Copyright © 2019 anddrrek. All rights reserved.
//

import Foundation

final class FileCreator {
    static let shared = FileCreator()
    
    //MARK: Constants
    private enum FileConstants: String {
        case name = "ImageKeys.swift"
        case importHeader = "import UIKit"
        case header = "enum ImageKeys: String"
        case casePrefix = "     case"
        case semicolon = "\""
    }
    
    private enum ExtensionSample: String {
        case name = "extension_sample"
        case type = "json"
    }
    
    //MARK: Initialization
    private init() {}
    
    //MARK: Logic
    private func createFileContent(_ content: [String]) -> String {
        var result = FileConstants.importHeader.rawValue + "\n\n"
        result += FileConstants.header.rawValue + " {\n"
        content.forEach({ text in
            let generatedText = "\(FileConstants.casePrefix.rawValue) \(text) = \(FileConstants.semicolon.rawValue)\(text)\(FileConstants.semicolon.rawValue)"
            
            result += generatedText
            result += "\n"
        })
        result += "}"
        result += "\n"
        result += loadExtensionSample()
        
        return result
    }
    
    private func loadExtensionSample() -> String {
        guard let samplePath = Bundle.main.path(forResource: ExtensionSample.name.rawValue,
                                                ofType: ExtensionSample.type.rawValue,
                                                inDirectory: nil),
            let sampleURL = URL(string: samplePath),
            let toSampleURL = URL(string: "file://\(sampleURL.absoluteString)") else {
            return ""
        }
        do {
            let sampleData = try Data(contentsOf: toSampleURL)
            let sampleString = String(data: sampleData, encoding: .utf8)
            return sampleString ?? ""
        } catch let error {
            print("create sample data error = \(error.localizedDescription)")
            return ""
        }
    }
    
    func createFile(at url: URL,
                    content: [String],
                    completion: @escaping (Error?)->Void) {
        let text = createFileContent(content)
        let data = text.data(using: .utf8, allowLossyConversion: false)
        let fileURL = url.appendingPathComponent(FileConstants.name.rawValue)
        do {
            try data?.write(to: fileURL)
            completion(nil)
        } catch let error {
            print("error write file \(error.localizedDescription)")
            completion(error)
        }
    }
}
