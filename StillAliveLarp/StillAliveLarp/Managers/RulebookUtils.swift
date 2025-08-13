//
//  RulebookUtils.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 10/6/23.
//

import Foundation
import SwiftUI
import SwiftSoup
import OrderedCollections

class RulebookUtils {
    
    fileprivate static let headingFont: UIFont = .systemFont(ofSize: 36, weight: .bold)
    fileprivate static let subheadingFont: UIFont = .systemFont(ofSize: 32, weight: .bold)
    fileprivate static let subsubheadingFont: UIFont = .systemFont(ofSize: 22, weight: .bold)
    fileprivate static let textFont: UIFont = .systemFont(ofSize: 16)
    fileprivate static let tableFont: UIFont = .systemFont(ofSize: 16)
    fileprivate static let tableHeadingFont: UIFont = .systemFont(ofSize: 16)

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
    
    static func parseDocAsRulebook(document: Document?, version: String) -> Rulebook {
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
                currentHeading?.title = globalStyleHtmlForRulebook((try? element.html()) ?? "").htmlString(headingFont)
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
                    currentSubHeading?.title = globalStyleHtmlForRulebook((try? element.html()) ?? "").htmlString(subheadingFont)
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
                    currentSubSubHeading?.title = globalStyleHtmlForRulebook((try? element.html()) ?? "").htmlString(subsubheadingFont)
                case Tags.TEXT:
                    if currentSubSubHeading != nil {
                        currentSubSubHeading?.addTextOrTable(globalStyleHtmlForRulebook((try? element.html()) ?? ""))
                    } else if currentSubHeading != nil {
                        currentSubHeading?.addTextOrTable(globalStyleHtmlForRulebook((try? element.html()) ?? ""))
                    } else {
                        currentHeading?.addTextOrTable(globalStyleHtmlForRulebook((try? element.html()) ?? ""))
                    }
                case Tags.TABLE:
                    let table = Table()
                    var keys = [AttributedString]()
                    for tableBody in element.children().array() {
                        for tableRow in tableBody.children().array() {
                            var firstTd = true
                            for tableElement in tableRow.children().array() {
                                switch tableElement.tagName() {
                                    case Tags.TABLEHEAD:
                                    keys.append(globalStyleHtmlForRulebook((try? tableElement.outerHtml()) ?? "").htmlString(tableHeadingFont))
                                case Tags.TABLEDETAIL:
                                    if firstTd {
                                        var count = 0
                                        for tableCell in tableRow.children().array() {
                                            if table.contents[keys[count]] == nil {
                                                table.contents[keys[count]] = [AttributedString]()
                                            }
                                            var tcell = globalStyleHtmlForRulebook((try? tableCell.outerHtml()) ?? "")
                                            tcell = tcell.replacingOccurrences(of: "<td>", with: "")
                                                .replacingOccurrences(of: "</td>", with: "")
                                                .replacingOccurrences(of: "<small>", with: "")
                                                .replacingOccurrences(of: "</small>", with: "")
                                            table.contents[keys[count]]?.append(tcell.htmlString(tableFont))
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
                    var keys = [AttributedString]()
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
                            txt = globalStyleHtmlForRulebook((try? li.children().first()?.children().first()?.html()) ?? "")
                        } else {
                            txt = globalStyleHtmlForRulebook((try? li.html()) ?? "")
                        }

                        if table.contents[keys[count]] == nil {
                            table.contents[keys[count]] = [AttributedString]()
                        }
                        table.contents[keys[count]]?.append(txt.htmlString(tableFont))
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
            names.append(heading.title.textValue)
            
            for subsub in heading.subSubHeadings {
                names.append("            \(subsub.title.textValue)")
            }
            
            for sub in heading.subHeadings {
                names.append("      \(sub.title.textValue)")
                for subsub in sub.subSubHeadings {
                    names.append("            \(subsub.title.textValue)")
                }
            }
        }
        return names
    }
}

class Heading: Identifiable, CustomCodeable {

    var title = AttributedString("")
    var order: [TextOrTable] = []
    var texts: [AttributedString] = []
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
        self.title = title.htmlString(.systemFont(ofSize: 36, weight: .bold))
        for tot in textsAndTables {
            if let t = tot as? Table {
                tables.append(t)
                order.append(.table)
            } else if let s = tot as? String {
                texts.append(s.htmlString(.systemFont(ofSize: 16)))
                order.append(.text)
            } else if let at = tot as? AttributedString {
                texts.append(at)
                order.append(.text)
            }
        }
        self.subSubHeadings = subSubHeadings
        self.subHeadings = subHeadings
    }
    
    convenience init(title: AttributedString, textsAndTables: [Any], subSubHeadings: [SubSubHeading], subHeadings: [SubHeading]) {
        self.init()
        self.title = title
        for tot in textsAndTables {
            if let t = tot as? Table {
                tables.append(t)
                order.append(.table)
            } else if let s = tot as? String {
                texts.append(s.htmlString(RulebookUtils.textFont))
                order.append(.text)
            } else if let at = tot as? AttributedString {
                texts.append(at)
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
            texts.append(s.htmlString(RulebookUtils.textFont))
            order.append(.text)
        } else if let at = textOrTable as? AttributedString {
            texts.append(at)
            order.append(.text)
        }
    }

    func contains(_ text: String) -> Bool {
        if title.textValue.containsIgnoreCase(text) {
            return true
        }
        if texts.first(where: { $0.textValue.containsIgnoreCase(text) }) != nil {
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
            if text.textValue.containsIgnoreCase(searchText) {
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
        if self.title.textValue.equalsIgnoreCase(title) {
            return true
        } else if self.subSubHeadings.first(where: { $0.title.textValue.equalsIgnoreCase(title) }) != nil {
            return true
        } else if self.subHeadings.first(where: { $0.title.textValue.equalsIgnoreCase(title) || ($0.subSubHeadings.first(where: { ssh in ssh.title.textValue.equalsIgnoreCase(title)}) != nil) }) != nil {
            return true
        }
        return false
    }
    
    func filterForHeadingsWithTitle(_ title: String) -> Heading {
        var newTextsAndTables = [Any]()
        var newSubSubHeadings = [SubSubHeading]()
        var newSubHeadings = [SubHeading]()
        
        if self.title.textValue.equalsIgnoreCase(title) {
            newTextsAndTables = textsAndTables
            newSubHeadings = subHeadings
            newSubSubHeadings = subSubHeadings
        }
        for subsub in subSubHeadings {
            if subsub.title.textValue.equalsIgnoreCase(title) {
                newSubSubHeadings.append(subsub)
            }
        }
        for sub in subHeadings {
            if sub.title.textValue.equalsIgnoreCase(title) {
                newSubHeadings.append(sub)
            } else if let subsub = sub.subSubHeadings.first(where: { $0.title.textValue.equalsIgnoreCase(title) }) {
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

    var title = AttributedString("")
    var order: [TextOrTable] = []
    var texts: [AttributedString] = []
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
        self.title = title.htmlString(RulebookUtils.subheadingFont)
        for tot in textsAndTables {
            if let t = tot as? Table {
                tables.append(t)
                order.append(.table)
            } else if let s = tot as? String {
                texts.append(s.htmlString(RulebookUtils.textFont))
                order.append(.text)
            } else if let at = tot as? AttributedString {
                texts.append(at)
                order.append(.text)
            }
        }
        self.subSubHeadings = subSubHeadings
    }
    
    convenience init(_ title: AttributedString, textsAndTables: [Any], subSubHeadings: [SubSubHeading]) {
        self.init()
        self.title = title
        for tot in textsAndTables {
            if let t = tot as? Table {
                tables.append(t)
                order.append(.table)
            } else if let s = tot as? String {
                texts.append(s.htmlString(RulebookUtils.textFont))
                order.append(.text)
            } else if let at = tot as? AttributedString {
                texts.append(at)
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
            texts.append(s.htmlString(RulebookUtils.textFont))
            order.append(.text)
        } else if let at = textOrTable as? AttributedString {
            texts.append(at)
            order.append(.text)
        }
    }

    func contains(_ text: String) -> Bool {
        if title.textValue.containsIgnoreCase(text) {
            return true
        }
        if texts.first(where: { $0.textValue.containsIgnoreCase(text) }) != nil {
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

    var title = AttributedString("")
    var order: [TextOrTable] = []
    var texts: [AttributedString] = []
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
        self.title = title.htmlString(RulebookUtils.subsubheadingFont)
        for tot in textsAndTables {
            if let t = tot as? Table {
                tables.append(t)
                order.append(.table)
            } else if let s = tot as? String {
                texts.append(s.htmlString(RulebookUtils.textFont))
                order.append(.text)
            } else if let at = tot as? AttributedString {
                texts.append(at)
                order.append(.text)
            }
        }
    }
    
    convenience init(_ title: AttributedString, textsAndTables: [Any]) {
        self.init()
        self.title = title
        for tot in textsAndTables {
            if let t = tot as? Table {
                tables.append(t)
                order.append(.table)
            } else if let s = tot as? String {
                texts.append(s.htmlString(RulebookUtils.textFont))
                order.append(.text)
            } else if let at = tot as? AttributedString {
                texts.append(at)
                order.append(.text)
            }
        }
    }
    
    func addTextOrTable(_ textOrTable: Any) {
        if let t = textOrTable as? Table {
            tables.append(t)
            order.append(.table)
        } else if let s = textOrTable as? String {
            texts.append(s.htmlString(RulebookUtils.textFont))
            order.append(.text)
        } else if let at = textOrTable as? AttributedString {
            texts.append(at)
            order.append(.text)
        }
    }

    func contains(_ text: String) -> Bool {
        if title.textValue.containsIgnoreCase(text) {
            return true
        }
        if texts.first(where: { $0.textValue.containsIgnoreCase(text) }) != nil {
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
        self.contents = OrderedDictionary(uniqueKeysWithValues: contents.map { (key, value) in
            (key.htmlString(RulebookUtils.tableHeadingFont), value.map { $0.htmlString(RulebookUtils.tableFont) })
        })
    }
    
    convenience init(contents: OrderedDictionary<AttributedString, [AttributedString]>) {
        self.init()
        self.contents = contents
    }

    var contents: OrderedDictionary<AttributedString, [AttributedString]> = [:]

    func convertToColumns() -> [[AttributedString]] {
        var listOfColumns = [[AttributedString]]()

        for kv in contents {
            var list = [AttributedString]()
            list.append(kv.key)
            list.append(contentsOf: kv.value)
            listOfColumns.append(list)
        }
        
        return listOfColumns
    }

    func convertToRows() -> [[AttributedString]] {
        var listOfRows = [[AttributedString]]()
        var list = [AttributedString]()
        for key in contents.keys {
            list.append(key)
        }
        listOfRows.append(list)
        var counter = 0
        for _ in contents.values.first ?? [] {
            var l = [AttributedString]()
            for key in contents.keys {
                l.append(contents[key]?[counter] ?? AttributedString(""))
            }
            counter += 1
            listOfRows.append(l)
        }
        return listOfRows
    }

    func contains(_ text: String) -> Bool {
        for kv in contents {
            if kv.key.textValue.containsIgnoreCase(text) {
                return true
            }
            for v in kv.value {
                if v.textValue.containsIgnoreCase(text) {
                    return true
                }
            }
        }
        return false
    }

}
