//
//  FolderContentHelper.swift
//  AssetGenerator
//
//  Created by Andrey on 12/04/2019.
//  Copyright © 2019 anddrrek. All rights reserved.
//

import Foundation

final class FolderContentHelper {
    static let shared = FolderContentHelper()
    
    private enum ExcludedFileTypes: String {
        case json = "json"
        case appiconset = "appiconset"
    }
    
    private enum Prefixes: String {
        case asset = "imageset"
        case assetExtension = ".imageset"
    }
    
    func getAllAssetNames(at url :URL) -> [String]? {
        do {
            let fileManager = FileManager.default
            let folderResources = try fileManager.contentsOfDirectory(at: url,
                                                                      includingPropertiesForKeys: nil,
                                                                      options: [.skipsHiddenFiles])
            let onlyDesiredResources = removeExcludedFiles(folderResources)
            
            let assetPrefix = Prefixes.asset.rawValue
            let assetExtension = Prefixes.assetExtension.rawValue

            var result = [String]()
            try onlyDesiredResources.forEach({ url in
                if url.pathExtension.contains(assetPrefix) {
                    let assetName = fileManager.displayName(atPath: url.path)
                    let clearName = assetName.replacingOccurrences(of: assetExtension, with: "")
                    result.append(clearName)
                } else {
                    let subDirectoryContent = try fileManager.contentsOfDirectory(at: url,
                                                                                  includingPropertiesForKeys: nil,
                                                                                  options: [.skipsHiddenFiles])
                    let desiredResources = findOnlyAssets(in: subDirectoryContent)
                    let clearNames = desiredResources.map({ url -> String? in
                        guard let name = url.pathComponents.last?.replacingOccurrences(of: assetExtension, with: "") else {
                            return nil
                        }
                        return name
                    }).compactMap({ $0 })
                    result.append(contentsOf: clearNames)
                }
            })
            let clearResult = Set(result)
            return Array(clearResult)
        } catch let error {
            print("errror = \(error.localizedDescription)")
            return nil
        }
    }
    
    private func removeExcludedFiles(_ files: [URL]) -> [URL] {
        return files.filter({ url in
             return !url.pathExtension.contains(ExcludedFileTypes.json.rawValue) && !url.pathExtension.contains(ExcludedFileTypes.appiconset.rawValue)
        })
    }
    
    private func findOnlyAssets(in directoryContents: [URL]) -> [URL] {
        return directoryContents.filter({ return $0.pathExtension.contains(Prefixes.asset.rawValue) })
    }
}
