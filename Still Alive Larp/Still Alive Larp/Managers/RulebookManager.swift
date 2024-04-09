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
        guard let rulebookString = LocalDataHandler.shared.getRulebook() else { return nil }
        return parseDocAsRulebook(document: try? SwiftSoup.parse(rulebookString), version: LocalDataHandler.shared.getRulebookVersion() ?? "Unknown Version")
    }

    func getOnlineVersion(callback: @escaping (_ rulebook: Rulebook?) -> Void) {
        // check version
        VersionService.getVersions { versions in
            let savedRulesVersion = LocalDataHandler.shared.getRulebookVersion()
            if savedRulesVersion != versions.rulebookVersion || LocalDataHandler.shared.getRulebook() == nil {
                // Download
                LocalDataHandler.shared.storeRulebookVersion(versions.rulebookVersion)
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
                        currentSubSubHeading?.textsAndTables.append((try? element.text()) ?? "")
                    } else if currentSubHeading != nil {
                        currentSubHeading?.textsAndTables.append((try? element.text()) ?? "")
                    } else {
                        currentHeading?.textsAndTables.append((try? element.text()) ?? "")
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
                        currentSubSubHeading?.textsAndTables.append(table)
                    } else if currentSubHeading != nil {
                        currentSubHeading?.textsAndTables.append(table)
                    } else {
                        currentHeading?.textsAndTables.append(table)
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
                        currentSubSubHeading?.textsAndTables.append(table)
                    } else if currentSubHeading != nil {
                        currentSubHeading?.textsAndTables.append(table)
                    } else {
                        currentHeading?.textsAndTables.append(table)
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
            LocalDataHandler.shared.storeRulebook(html)
            onSuccess(parseDocAsRulebook(document: try SwiftSoup.parse(html), version: version))
        } catch {
            onFailure()
        }
    }

}

class Rulebook {
    let version: String
    var headings = [Heading]()

    init(version: String) {
        self.version = version
    }
}

class Heading: Identifiable {

    var title = ""
    var textsAndTables = [Any]()
    var subSubHeadings = [SubSubHeading]()
    var subHeadings = [SubHeading]()

    convenience init(title: String, textsAndTables: [Any], subSubHeadings: [SubSubHeading], subHeadings: [SubHeading]) {
        self.init()
        self.title = title
        self.textsAndTables = textsAndTables
        self.subSubHeadings = subSubHeadings
        self.subHeadings = subHeadings
    }

    func contains(_ text: String) -> Bool {
        if title.containsIgnoreCase(text) {
            return true
        }
        for tot in textsAndTables {
            if (tot as? Table)?.contains(text) ?? false {
                return true
            } else if (tot as? String)?.containsIgnoreCase(text) ?? false {
                return true
            }
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

    func clone() -> Heading {
        return Heading(title: title, textsAndTables: textsAndTables, subSubHeadings: subSubHeadings, subHeadings: subHeadings)
    }

}

class SubHeading: Identifiable {

    var title = ""
    var textsAndTables = [Any]()
    var subSubHeadings = [SubSubHeading]()

    convenience init(_ title: String, textsAndTables: [Any], subSubHeadings: [SubSubHeading]) {
        self.init()
        self.title = title
        self.textsAndTables = textsAndTables
        self.subSubHeadings = subSubHeadings
    }

    func contains(_ text: String) -> Bool {
        if title.containsIgnoreCase(text) {
            return true
        }
        for tot in textsAndTables {
            if (tot as? Table)?.contains(text) ?? false {
                return true
            } else if (tot as? String)?.containsIgnoreCase(text) ?? false {
                return true
            }
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

class SubSubHeading: Identifiable {

    var title = ""
    var textsAndTables = [Any]()

    convenience init(_ title: String, textsAndTables: [Any]) {
        self.init()
        self.title = title
        self.textsAndTables = textsAndTables
    }

    func contains(_ text: String) -> Bool {
        if title.containsIgnoreCase(text) {
            return true
        }
        for tot in textsAndTables {
            if (tot as? Table)?.contains(text) ?? false {
                return true
            } else if (tot as? String)?.containsIgnoreCase(text) ?? false {
                return true
            }
        }
        return false
    }

    func clone() -> SubSubHeading {
        return SubSubHeading(title, textsAndTables: textsAndTables)
    }

}

class Table: Identifiable {

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
