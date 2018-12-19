//
//  SwiftGenerator.swift
//  Loco
//
//  Created by Tamas Bara on 19.12.18.
//  Copyright © 2018 de.check24. All rights reserved.
//

import Foundation

enum SwiftGenerator {
    
    private static let header = "import ObjectMapper\n\nstruct #N {\n"
    private static let extenzion = "}\n\nextension #N: Mappable {\n\n    init?(map: Map) {}\n\n    mutating func mapping(map: Map) {\n"
    private static let footer = "    }\n}\n"
    
    private static var files: [String: String] = [:]
    
    static func generate(_ json: [String: AnyObject]) -> [String: String] {
        files.removeAll()
        addFile(json, key: "Foo")
        return files
    }
    
    private static func omRep(_ object: AnyObject, key: String) -> String {
        switch object {
        case is String:
            return "String"
        case is Bool:
            return "Bool"
        case is Int:
            return "Int"
        case is NSDictionary:
            addFile(object, key: key.capitalizingFirstLetter())
            return key.capitalizingFirstLetter()
        case is NSArray:
            addFile(object, key: key.capitalizingFirstLetter())
            return "[\(key.capitalizingFirstLetter())]"
        default:
            return "unknown"
        }
    }
    
    private static func addFile(_ object: AnyObject, key: String) {
        guard let json = object as? [String: AnyObject] ?? (object as? NSArray)?.firstObject as? [String: AnyObject] else {return}
        addFile(json, key: key)
    }
    
    private static func addFile(_ json: [String: AnyObject], key: String) {
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
