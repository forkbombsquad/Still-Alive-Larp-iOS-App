//
//  ViewRulesView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 10/6/23.
//

import SwiftUI

@ViewBuilder
fileprivate func createTextView(_ text: String) -> some View {
    AttributedTextView(attributedString: ("    " + text).htmlString()).font(.system(size: 16)).padding(.bottom, 16).padding(.horizontal, 8).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
}

struct ViewRulesView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @State var searchText: String = ""
    let rulebook: Rulebook?
    
    @State var filter: String = "No Filter"
    var allFilters: [String]
    
    init(rulebook: Rulebook?) {
        self.rulebook = rulebook
        allFilters = ["No Filter"]
        allFilters.append(contentsOf: rulebook?.getAllFilterableHeadingNames() ?? [])
        _filter = globalState("No Filter")
    }

    var body: some View {
        GeometryReader { gr in
            VStack {
                Text(DM.getTitlePotentiallyOffline("Rulebook v\(rulebook?.version ?? "unknown version")"))
                    .font(.stillAliveTitleFont)
                    .frame(alignment: .center)
                Menu("Filter\n(\(sanitizeFilter()))") {
                    ForEach(allFilters, id: \.self) { filter in
                        Button(filter) {
                            self.filter = filter
                        }
                    }
                }
                .font(.system(size: 16, weight: .bold))
                .padding(.top, -16)
                TextField("Search", text: $searchText)
                    .padding([.horizontal, .bottom], 16)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                ScrollView(.vertical) {
                    ForEach(filterHeadings()) { heading in
                        HeadingView(heading: heading, width: gr.size.width)
                            .background(Color.lightGray)
                            .padding(2)
                    }
                }
            }
            .background(Color.lightGray)
        }
    }

    private func filterHeadings() -> [Heading] {
        var headings = rulebook?.headings ?? []
        if !filter.equalsIgnoreCase("No Filter") {
            headings = headings.filter({ $0.titlesContain(sanitizeFilter())
            })
            headings = getFilteredHeadings(headings)
        }
        let st = searchText.trimmed
        if (!st.isEmpty) {
            let filteredHeadings = headings.filter({ $0.contains(st) })
            return furtherFilterHeadings(filteredHeadings, searchText: st)
        } else {
            return headings
        }
    }
    
    private func furtherFilterHeadings(_ headings: [Heading], searchText: String) -> [Heading] {
        var newHeadings = [Heading]()
        for heading in headings {
            newHeadings.append(heading.filterTextCallContainsFirst(searchText))
        }
        return newHeadings
    }
    
    private func getFilteredHeadings(_ headings: [Heading]) -> [Heading] {
        var newHeadings = [Heading]()
        for heading in headings {
            newHeadings.append(heading.filterForHeadingsWithTitle(sanitizeFilter()))
        }
        return newHeadings
    }
    
    private func sanitizeFilter() -> String {
        return filter.trim()
    }

}

struct HeadingView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let heading: Heading
    let width: CGFloat

    var body: some View {
        BlackCardView2pxPadding {
            VStack {
                AttributedTextView(attributedString: heading.title.htmlString())
                    .multilineTextAlignment(.center)
                    .font(.system(size: 36))
                    .underline()
                    .fontWeight(.bold)
                    .padding(8)
                ForEach(0 ..< heading.textsAndTables.count, id: \.self) { index in
                    if let table = heading.textsAndTables[index] as? Table {
                        CustomTableView(table: table)
                            .padding(16)
                    } else if let text = heading.textsAndTables[index] as? String {
                        createTextView(text)
                    }
                }
                ForEach(heading.subSubHeadings) { subSubHeading in
                    SubSubHeadingView(subSubHeading: subSubHeading, width: width)
                }
                ForEach(heading.subHeadings) { subHeading in
                    SubHeadingView(subHeading: subHeading, width: width)
                }
            }
        }
    }
}

struct SubHeadingView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let subHeading: SubHeading
    let width: CGFloat

    var body: some View {
        VStack {
            AttributedTextView(attributedString: subHeading.title.htmlString())
                .multilineTextAlignment(.leading)
                .font(.system(size: 32))
                .italic()
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
            ForEach(0 ..< subHeading.textsAndTables.count, id: \.self) { index in
                if let table = subHeading.textsAndTables[index] as? Table {
                    CustomTableView(table: table)
                        .padding(16)
                } else if let text = subHeading.textsAndTables[index] as? String {
                    createTextView(text)
                }
            }
            ForEach(subHeading.subSubHeadings) { subSubHeading in
                SubSubHeadingView(subSubHeading: subSubHeading, width: width)
            }
        }
    }
}

struct SubSubHeadingView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let subSubHeading: SubSubHeading
    let width: CGFloat

    var body: some View {
        VStack {
            AttributedTextView(attributedString: subSubHeading.title.htmlString())
                .multilineTextAlignment(.leading)
                .font(.system(size: 22))
                .underline()
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
            ForEach(0 ..< subSubHeading.textsAndTables.count, id: \.self) { index in
                if let table = subSubHeading.textsAndTables[index] as? Table {
                    CustomTableView(table: table)
                        .padding(16)
                } else if let text = subSubHeading.textsAndTables[index] as? String {
                    createTextView(text)
                }
            }
        }
    }
}

struct CustomTableView: View {
    
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    let cols: [[String]]
    let rows: [[String]]
    var minWidths: [Int] = []
    var minHeights: [Int] = []
    
    init(table: Table) {
        self.cols = table.convertToColumns()
        self.rows = table.convertToRows()
        for col in cols {
            minWidths.append(getMinWidth(col: col))
        }
        for row in rows {
            minHeights.append(getMinHeight(row: row))
        }
    }
    
    func getMinWidth(col: [String]) -> Int {
        return min(max((col.map { $0.count }.max() ?? 0) * 8, 100), 400)
    }
    
    func getMinHeight(row: [String]) -> Int {
        var mx = 0
        for (index, cell) in row.enumerated() {
            let font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 4)
            let constraintRect = CGSize(width: CGFloat(minWidths[index]), height: CGFloat.greatestFiniteMagnitude)
            let boundingBox = cell.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
            mx = max(mx, Int(ceil(boundingBox.height)) + 16)
        }
        return max(mx, 44)
    }

    var body: some View {
        ScrollView(.horizontal) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<rows.count, id: \.self) { rowIndex in
                    HStack(spacing: 0) {
                        ForEach(0..<rows[rowIndex].count, id: \.self) { colIndex in
                            let uneditedText = rows[rowIndex][colIndex]
                            let text = uneditedText.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: "")
                            TableCell(
                                text: text,
                                isHeader: rowIndex == 0,
                                width: minWidths[colIndex],
                                height: minHeights[rowIndex]
                            )
                        }
                    }
                }
            }
        }
    }
    
    struct TableCell: View {
        let text: String
        let isHeader: Bool
        let width: Int
        let height: Int

        var body: some View {
            AttributedTextView(attributedString: text.htmlString())
                .multilineTextAlignment(.center)
                .frame(height: CGFloat(height))
                .frame(width: CGFloat(width))
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(Color.lightGray)
                .border(Color.black, width: 0.5)
        }
    }

}


#Preview {
    DataManager.shared.setDebugMode(true)
    let md = getMockData()
    return ViewRulesView(rulebook: md.rulebook)
}
