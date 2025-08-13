//
//  ViewRulesView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 10/6/23.
//

import SwiftUI

@ViewBuilder
fileprivate func createTextView(_ text: AttributedString) -> some View {
    Text(text).font(.system(size: 16)).padding(.bottom, 16).padding(.horizontal, 8).multilineTextAlignment(.leading).frame(maxWidth: .infinity, alignment: .leading)
}

struct ViewRulesView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    @State var searchText: String = ""
    let rulebook: Rulebook?
    
    @State var filter: String = "No Filter"
    var allFilters: [String]
    
    @State var showFilters: Bool = false
    
    init(rulebook: Rulebook?) {
        self.rulebook = rulebook
        allFilters = ["No Filter"]
        allFilters.append(contentsOf: rulebook?.getAllFilterableHeadingNames() ?? [])
        _filter = globalState("No Filter")
    }

    var body: some View {
        VStack {
            GeometryReader { gr in
                VStack {
                    Text(DM.getTitlePotentiallyOffline("Rulebook v\(rulebook?.version ?? "unknown version")"))
                        .font(.stillAliveTitleFont)
                        .frame(alignment: .center)
                    Button(action: {
                        showFilters.toggle()
                    }) {
                        HStack {
                            Spacer()
                            Text("Filter\n(\(sanitizeFilter()))")
                                .frame(alignment: .center)
                                .font(.system(size: 16, weight: .bold))
                                .padding(.top, -16)
                            Image(systemName: "chevron.down")
                            Spacer()
                        }
                        .frame(width: gr.size.width)
                    }.popover(isPresented: $showFilters) {
                        ScrollView {
                            ForEach(allFilters, id: \.self) { filter in
                                Button(action: {
                                    self.filter = filter
                                    showFilters = false
                                }) {
                                    HStack {
                                        let headingLevel: CGFloat = filter.hasPrefix("            ") ? 2 : (filter.hasPrefix("      ") ? 1 : 0)
                                        let size: CGFloat = 18 - (headingLevel * 2)
                                        let weight: Font.Weight = (headingLevel == 0 ? .bold : (headingLevel == 1 ? .semibold : .regular))
                                        Text(filter)
                                            .font(.system(size: size, weight: weight))
                                            .foregroundColor(.black)
                                            .frame(alignment: .leading)
                                            .padding([.horizontal], 8)
                                        Spacer()
                                    }
                                }
                                .frame(alignment: .leading)
                                .padding([.top, .horizontal], 8)
                            }
                        }
                        .background(Color.lightGray)
                        .frame(width: UIScreen.main.bounds.width * 0.9, alignment: .leading)
                        .presentationBackground(Color.lightGray)
                        .presentationCompactAdaptation(.popover)
                    }
                    TextField("Search", text: $searchText)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
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
                Text(heading.title)
                    .multilineTextAlignment(.center)
                    .underline()
                    .padding(8)
                ForEach(0 ..< heading.textsAndTables.count, id: \.self) { index in
                    if let table = heading.textsAndTables[index] as? Table {
                        CustomTableView(table: table)
                            .padding(16)
                    } else if let text = heading.textsAndTables[index] as? AttributedString {
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
            .frame(width: width - 16, alignment: .center)
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
            Text(subHeading.title)
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
                } else if let text = subHeading.textsAndTables[index] as? AttributedString {
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
            Text(subSubHeading.title)
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
                } else if let text = subSubHeading.textsAndTables[index] as? AttributedString {
                    createTextView(text)
                }
            }
        }
    }
}

struct CustomTableView: View {
    
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    let cols: [[AttributedString]]
    let rows: [[AttributedString]]
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
    
    func getMinWidth(col: [AttributedString]) -> Int {
        return min(max((col.map { $0.textValue.count }.max() ?? 0) * 8, 100), 400)
    }
    
    func getMinHeight(row: [AttributedString]) -> Int {
        var mx = 0
        for (index, cell) in row.enumerated() {
            let font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 4)
            let constraintRect = CGSize(width: CGFloat(minWidths[index]), height: CGFloat.greatestFiniteMagnitude)
            let boundingBox = cell.textValue.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
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
                            TableCell(
                                text: rows[rowIndex][colIndex],
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
        let text: AttributedString
        let width: Int
        let height: Int

        var body: some View {
            Text(text)
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
    return ViewRulesView(rulebook: md.rulebook).environmentObject(DataManager.shared)
}
