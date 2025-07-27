//
//  RulebookManager.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 10/6/23.
//

import Foundation
import SwiftSoup
import OrderedCollections

class RulebookManager {

    private struct Tags {
        static let HEADING = "h1"
        static let SUBHEADING = "h2"
        static let SUBSUBHEADING = "h3"
        static let TEXT = "p"
        static let TABLE = "table"
        static let LIST = "ul"
        static let TABLEROW = "tr"
        static let TABLEHEAD = "th"
        static let TABLEDETAIL = "td"
    }

    static let shared = RulebookManager()

    private init() {}

    func getOfflineVersion() -> Rulebook? {
        guard let rulebookString = OldLocalDataHandler.shared.getRulebook() else { return nil }
        return parseDocAsRulebook(document: try? SwiftSoup.parse(rulebookString), version: OldLocalDataHandler.shared.getRulebookVersion() ?? "Unknown Version")
    }

    func getOnlineVersion(callback: @escaping (_ rulebook: Rulebook?) -> Void) {
        // check version
        VersionService.getVersions { versions in
            let savedRulesVersion = OldLocalDataHandler.shared.getRulebookVersion()
            if savedRulesVersion != versions.rulebookVersion || OldLocalDataHandler.shared.getRulebook() == nil {
                // Download
                OldLocalDataHandler.shared.storeRulebookVersion(versions.rulebookVersion)
                self.downloadPage(version: versions.rulebookVersion) { rulebook in
                    callback(rulebook)
                } onFailure: {
                    callback(nil)
                }

            } else {
                // Load from local data
                callback(self.getOfflineVersion())
            }
        } failureCase: { error in
            callback(nil)
        }

    }

    private func parseDocAsRulebook(document: Document?, version: String) -> Rulebook {
        let content = try? document?.getElementById("AppContent")
        let elements = content?.children().array() ?? []
        let rulebook = Rulebook(version: version)
        var currentHeading: Heading?
        var currentSubHeading: SubHeading?
        var currentSubSubHeading: SubSubHeading?

        for element in elements {
            switch element.tagName() {
                case Tags.HEADING:
                    if let cssh = currentSubSubHeading {
                        if currentSubHeading == nil {
                            currentHeading?.subSubHeadings.append(cssh.clone())
                        } else {
                            currentSubHeading?.subSubHeadings.append(cssh.clone())
                        }
                        currentSubSubHeading = nil
                    }
                    if let csh = currentSubHeading {
                        currentHeading?.subHeadings.append(csh.clone())
                        currentSubHeading = nil
                    }
                    if let ch = currentHeading {
                        rulebook.headings.append(ch.clone())
                        currentHeading = nil
                    }
                    currentHeading = Heading()
                    currentHeading?.title = (try? element.text()) ?? ""
                case Tags.SUBHEADING:
                    if let cssh = currentSubSubHeading {
                        if currentSubHeading == nil {
                            currentHeading?.subSubHeadings.append(cssh.clone())
                        } else {
                            currentSubHeading?.subSubHeadings.append(cssh.clone())
                        }
                        currentSubSubHeading = nil
                    }
                    if let csh = currentSubHeading {
                        currentHeading?.subHeadings.append(csh.clone())
                        currentSubHeading = nil
                    }
                    currentSubHeading = SubHeading()
                    currentSubHeading?.title = (try? element.text()) ?? ""
                case Tags.SUBSUBHEADING:
                    if let cssh = currentSubSubHeading {
                        if currentSubHeading == nil {
                            currentHeading?.subSubHeadings.append(cssh.clone())
                        } else {
                            currentSubHeading?.subSubHeadings.append(cssh.clone())
                        }
                        currentSubSubHeading = nil
                    }
                    currentSubSubHeading = SubSubHeading()
                    currentSubSubHeading?.title = (try? element.text()) ?? ""
                case Tags.TEXT:
                    if currentSubSubHeading != nil {
                        currentSubSubHeading?.addTextOrTable((try? element.text()) ?? "")
                    } else if currentSubHeading != nil {
                        currentSubHeading?.addTextOrTable((try? element.text()) ?? "")
                    } else {
                        currentHeading?.addTextOrTable((try? element.text()) ?? "")
                    }
                case Tags.TABLE:
                    let table = Table()
                    var keys = [String]()
                    for tableBody in element.children().array() {
                        for tableRow in tableBody.children().array() {
                            var firstTd = true
                            for tableElement in tableRow.children().array() {
                                switch tableElement.tagName() {
                                    case Tags.TABLEHEAD:
                                        keys.append((try? tableElement.text()) ?? "")
                                case Tags.TABLEDETAIL:
                                    if firstTd {
                                        var count = 0
                                        for tableCell in tableRow.children().array() {
                                            if table.contents[keys[count]] == nil {
                                                table.contents[keys[count]] = [String]()
                                            }
                                            var tcell = (try? tableCell.outerHtml()) ?? ""
                                            tcell = tcell.replacingOccurrences(of: "<td>", with: "")
                                                .replacingOccurrences(of: "</td>", with: "")
                                                .replacingOccurrences(of: "<small>", with: "")
                                                .replacingOccurrences(of: "</small>", with: "")
                                                .replacingOccurrences(of: "<br>", with: "\n")
                                            table.contents[keys[count]]?.append(tcell)
                                            count += 1
                                        }
                                    }
                                    firstTd = false
                                    default:
                                        break
                                }
                            }
                        }
                    }
                    if currentSubSubHeading != nil {
                        currentSubSubHeading?.addTextOrTable(table)
                    } else if currentSubHeading != nil {
                        currentSubHeading?.addTextOrTable(table)
                    } else {
                        currentHeading?.addTextOrTable(table)
                    }
                case Tags.LIST:
                    let table = Table()
                    var keys = [String]()
                    keys.append("Category")
                    keys.append("Change")
                    for li in element.children().array() {
                        var count = 0
                        if li.children().first()?.tagName() == Tags.LIST {
                            count = 1
                        } else {
                            count = 0
                        }

                        var txt = ""
                        if count == 1 {
                            txt = (try? li.children().first()?.children().first()?.text()) ?? ""
                        } else {
                            txt = (try? li.text()) ?? ""
                        }

                        if table.contents[keys[count]] == nil {
                            table.contents[keys[count]] = [String]()
                        }
                        table.contents[keys[count]]?.append(txt)
                    }
                    if currentSubSubHeading != nil {
                        currentSubSubHeading?.addTextOrTable(table)
                    } else if currentSubHeading != nil {
                        currentSubHeading?.addTextOrTable(table)
                    } else {
                        currentHeading?.addTextOrTable(table)
                    }
                default:
                    break
            }
        }

        if let cssh = currentSubSubHeading {
            if currentSubHeading == nil {
                currentHeading?.subSubHeadings.append(cssh.clone())
            } else {
                currentSubHeading?.subSubHeadings.append(cssh.clone())
            }
            currentSubSubHeading = nil
        }
        if let csh = currentSubHeading {
            currentHeading?.subHeadings.append(csh.clone())
            currentSubHeading = nil
        }
        if let ch = currentHeading {
            rulebook.headings.append(ch.clone())
            currentHeading = nil
        }

        return rulebook

    }

    private func downloadPage(version: String, onSuccess: (_ rulebook: Rulebook) -> Void, onFailure: () -> Void) {
        guard let url = URL(string: Constants.urls.rulebook) else {
            onFailure()
            return
        }
        do {
            let html = try String(contentsOf: url)
            OldLocalDataHandler.shared.storeRulebook(html)
            onSuccess(parseDocAsRulebook(document: try SwiftSoup.parse(html), version: version))
        } catch {
            onFailure()
        }
    }

}

class Rulebook: CustomCodeable {
    let version: String
    var headings = [Heading]()

    init(version: String) {
        self.version = version
    }
    
    init(version: String, headings: [Heading]) {
        self.version = version
        self.headings = headings
    }
    
    func getAllFilterableHeadingNames() -> [String] {
        var names = [String]()
        for heading in headings {
            names.append(heading.title)
            
            for subsub in heading.subSubHeadings {
                names.append("            \(subsub.title)")
            }
            
            for sub in heading.subHeadings {
                names.append("      \(sub.title)")
                for subsub in sub.subSubHeadings {
                    names.append("            \(subsub.title)")
                }
            }
        }
        return names
    }
}

class Heading: Identifiable, CustomCodeable {

    var title = ""
    var order: [TextOrTable] = []
    var texts: [String] = []
    var tables: [Table] = []
    var subSubHeadings = [SubSubHeading]()
    var subHeadings = [SubHeading]()
    
    var textsAndTables: [Any] {
        var textIndex = 0
        var tableIndex = 0
        var tat = [Any]()
        for o in order {
            switch o {
            case .text:
                tat.append(texts[textIndex])
                textIndex += 1
            case .table:
                tat.append(tables[tableIndex])
                tableIndex += 1
            }
        }
        return tat
    }

    convenience init(title: String, textsAndTables: [Any], subSubHeadings: [SubSubHeading], subHeadings: [SubHeading]) {
        self.init()
        self.title = title
        for tot in textsAndTables {
            if let t = tot as? Table {
                tables.append(t)
                order.append(.table)
            } else if let s = tot as? String {
                texts.append(s)
                order.append(.text)
            }
        }
        self.subSubHeadings = subSubHeadings
        self.subHeadings = subHeadings
    }
    
    func addTextOrTable(_ textOrTable: Any) {
        if let t = textOrTable as? Table {
            tables.append(t)
            order.append(.table)
        } else if let s = textOrTable as? String {
            texts.append(s)
            order.append(.text)
        }
    }

    func contains(_ text: String) -> Bool {
        if title.containsIgnoreCase(text) {
            return true
        }
        if texts.first(where: { $0.containsIgnoreCase(text) }) != nil {
            return true
        }
        if tables.first(where: { $0.contains(text) }) != nil {
            return true
        }
        for subSubHeading in subSubHeadings {
            if subSubHeading.contains(text) {
                return true
            }
        }
        for subHeading in subHeadings {
            if subHeading.contains(text) {
                return true
            }
        }
        return false
    }
    
    func filterTextCallContainsFirst(_ searchText: String) -> Heading {
        var newTextsAndTables = [Any]()
        var newSubSubHeadings = [SubSubHeading]()
        var newSubHeadings = [SubHeading]()
        
        for text in texts {
            if text.containsIgnoreCase(searchText) {
                newTextsAndTables.append(text)
            }
        }
        
        for table in tables {
            if table.contains(searchText) {
                newTextsAndTables.append(table)
            }
        }
        
        for subsub in subSubHeadings {
            if subsub.contains(searchText) {
                newSubSubHeadings.append(subsub)
            }
        }
        for sub in subHeadings {
            if sub.contains(searchText) {
                newSubHeadings.append(sub)
            }
        }
        
        return Heading(title: title, textsAndTables: newTextsAndTables, subSubHeadings: newSubSubHeadings, subHeadings: newSubHeadings)
    }
    
    func titlesContain(_ title: String) -> Bool {
        if self.title.equalsIgnoreCase(title) {
            return true
        } else if self.subSubHeadings.first(where: { $0.title.equalsIgnoreCase(title) }) != nil {
            return true
        } else if self.subHeadings.first(where: { $0.title.equalsIgnoreCase(title) || ($0.subSubHeadings.first(where: { ssh in ssh.title.equalsIgnoreCase(title)}) != nil) }) != nil {
            return true
        }
        return false
    }
    
    func filterForHeadingsWithTitle(_ title: String) -> Heading {
        var newTextsAndTables = [Any]()
        var newSubSubHeadings = [SubSubHeading]()
        var newSubHeadings = [SubHeading]()
        
        if self.title.equalsIgnoreCase(title) {
            newTextsAndTables = textsAndTables
            newSubHeadings = subHeadings
            newSubSubHeadings = subSubHeadings
        }
        for subsub in subSubHeadings {
            if subsub.title.equalsIgnoreCase(title) {
                newSubSubHeadings.append(subsub)
            }
        }
        for sub in subHeadings {
            if sub.title.equalsIgnoreCase(title) {
                newSubHeadings.append(sub)
            } else if let subsub = sub.subSubHeadings.first(where: { $0.title.equalsIgnoreCase(title) }) {
                newSubHeadings.append(SubHeading(sub.title, textsAndTables: [], subSubHeadings: [subsub]))
            }
        }
        
        return Heading(title: self.title, textsAndTables: newTextsAndTables, subSubHeadings: newSubSubHeadings, subHeadings: newSubHeadings)
    }

    func clone() -> Heading {
        return Heading(title: title, textsAndTables: textsAndTables, subSubHeadings: subSubHeadings, subHeadings: subHeadings)
    }

}

class SubHeading: Identifiable, CustomCodeable {

    var title = ""
    var order: [TextOrTable] = []
    var texts: [String] = []
    var tables: [Table] = []
    var subSubHeadings = [SubSubHeading]()
    
    var textsAndTables: [Any] {
        var textIndex = 0
        var tableIndex = 0
        var tat = [Any]()
        for o in order {
            switch o {
            case .text:
                tat.append(texts[textIndex])
                textIndex += 1
            case .table:
                tat.append(tables[tableIndex])
                tableIndex += 1
            }
        }
        return tat
    }

    convenience init(_ title: String, textsAndTables: [Any], subSubHeadings: [SubSubHeading]) {
        self.init()
        self.title = title
        for tot in textsAndTables {
            if let t = tot as? Table {
                tables.append(t)
                order.append(.table)
            } else if let s = tot as? String {
                texts.append(s)
                order.append(.text)
            }
        }
        self.subSubHeadings = subSubHeadings
    }
    
    func addTextOrTable(_ textOrTable: Any) {
        if let t = textOrTable as? Table {
            tables.append(t)
            order.append(.table)
        } else if let s = textOrTable as? String {
            texts.append(s)
            order.append(.text)
        }
    }

    func contains(_ text: String) -> Bool {
        if title.containsIgnoreCase(text) {
            return true
        }
        if texts.first(where: { $0.containsIgnoreCase(text) }) != nil {
            return true
        }
        if tables.first(where: { $0.contains(text) }) != nil {
            return true
        }
        for subSubHeading in subSubHeadings {
            if subSubHeading.contains(text) {
                return true
            }
        }
        return false
    }

    func clone() -> SubHeading {
        return SubHeading(title, textsAndTables: textsAndTables, subSubHeadings: subSubHeadings)
    }

}

class SubSubHeading: Identifiable, CustomCodeable {

    var title = ""
    var order: [TextOrTable] = []
    var texts: [String] = []
    var tables: [Table] = []
    
    var textsAndTables: [Any] {
        var textIndex = 0
        var tableIndex = 0
        var tat = [Any]()
        for o in order {
            switch o {
            case .text:
                tat.append(texts[textIndex])
                textIndex += 1
            case .table:
                tat.append(tables[tableIndex])
                tableIndex += 1
            }
        }
        return tat
    }

    convenience init(_ title: String, textsAndTables: [Any]) {
        self.init()
        self.title = title
        for tot in textsAndTables {
            if let t = tot as? Table {
                tables.append(t)
                order.append(.table)
            } else if let s = tot as? String {
                texts.append(s)
                order.append(.text)
            }
        }
    }
    
    func addTextOrTable(_ textOrTable: Any) {
        if let t = textOrTable as? Table {
            tables.append(t)
            order.append(.table)
        } else if let s = textOrTable as? String {
            texts.append(s)
            order.append(.text)
        }
    }

    func contains(_ text: String) -> Bool {
        if title.containsIgnoreCase(text) {
            return true
        }
        if texts.first(where: { $0.containsIgnoreCase(text) }) != nil {
            return true
        }
        if tables.first(where: { $0.contains(text) }) != nil {
            return true
        }
        return false
    }

    func clone() -> SubSubHeading {
        return SubSubHeading(title, textsAndTables: textsAndTables)
    }

}

enum TextOrTable: Codable {
    case text, table
}

class Table: Identifiable, CustomCodeable {
    
    convenience init(contents: OrderedDictionary<String, [String]>) {
        self.init()
        self.contents = contents
    }

    var contents: OrderedDictionary<String, [String]> = [:]

    func convertToColumns() -> [[String]] {
        var listOfColumns = [[String]]()

        for kv in contents {
            var list = [String]()
            list.append(kv.key)
            list.append(contentsOf: kv.value)
            listOfColumns.append(list)
        }
        
        return listOfColumns
    }

    func convertToRows() -> [[String]] {
        var listOfRows = [[String]]()
        var list = [String]()
        for key in contents.keys {
            list.append(key)
        }
        listOfRows.append(list)
        var counter = 0
        for _ in contents.values.first ?? [] {
            var l = [String]()
            for key in contents.keys {
                l.append(contents[key]?[counter] ?? "")
            }
            counter += 1
            listOfRows.append(l)
        }
        return listOfRows
    }

    func contains(_ text: String) -> Bool {
        for kv in contents {
            if kv.key.containsIgnoreCase(text) {
                return true
            }
            for v in kv.value {
                if v.containsIgnoreCase(text) {
                    return true
                }
            }
        }
        return false
    }

}
