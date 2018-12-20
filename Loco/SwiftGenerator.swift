//
//  SwiftGenerator.swift
//  Loco
//
//  Created by Tamas Bara on 19.12.18.
//  Copyright © 2018 de.check24. All rights reserved.
//

import Foundation

enum SwiftGenerator {
    
    private static let header = "\nimport ObjectMapper\n\nstruct #N {\n"
    private static let extenzion = "}\n\nextension #N: Mappable {\n\n    init?(map: Map) {}\n\n    mutating func mapping(map: Map) {\n"
    private static let footer = "    }\n}\n"
    
    private static var files: [String: String] = [:]
    
    static func generate(_ json: [String: Any]) -> [String: String] {
        files.removeAll()
        addFile(json, key: "Foo")
        return files
    }
    
    private static func omRep(_ object: Any, key: String) -> String {
        
        let mirror = Mirror(reflecting: object)
        let subjectType = "\(mirror.subjectType)"
        if subjectType.contains("Bool") {
            return "Bool"
        }
        
        switch object {
        case is String:
            
            let links = ["href", "link"]
            if links.filter({key.lowercased().contains($0)}).count > 0 {
                return "URL"
            }
            
            if (object as? String)?.contains("http") == true {
                return "URL"
            }
            
            let dates = ["datum", "burtstag"]
            if dates.filter({key.lowercased().contains($0)}).count > 0 {
                return "Date"
            }
            
            return "String"
        
        case is Int:
            return "Int"
            
        case is Double:
            return "Double"
        
        case is NSDictionary:
            let camelKey = key.capitalizingFirstLetter().camelCasedString
            addFile(object, key: camelKey)
            return camelKey
            
        case is NSArray:
            
            var camelKey = key.capitalizingFirstLetter().camelCasedString
            let suffixes = ["e", "s", "List", "Liste"]
            if let suffix = suffixes.filter({camelKey.hasSuffix($0)}).last {
                camelKey = String(camelKey.dropLast(suffix.count))
            }
            addFile(object, key: camelKey)
            return "[\(camelKey)]"
        
        default:
            return "unknown"
        }
    }
    
    private static func addFile(_ object: Any, key: String) {
        guard let json = object as? [String: Any] ?? (object as? NSArray)?.firstObject as? [String: Any] else {return}
        addFile(json, key: key)
    }
    
    private static func addFile(_ json: [String: Any], key: String) {
        var topSwift = header.replacingOccurrences(of: "#N", with: key)
        var bottomSwift = extenzion.replacingOccurrences(of: "#N", with: key)
        for (key, value) in json {
            topSwift += "    var \(key.camelCasedString): \(omRep(value, key: key))?\n"
            bottomSwift += "        \(key.camelCasedString) <- map[\"\(key)\"]\n"
        }
        
        files[key] = topSwift + bottomSwift + footer
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    var camelCasedString: String {
        let comps = components(separatedBy: "_")
        guard comps.count > 1 else {return self}
        return (comps.first ?? "") + comps.dropFirst().map({$0.capitalizingFirstLetter()}).joined()
    }
}
