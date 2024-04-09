//
//  ViewRulesView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 10/6/23.
//

import SwiftUI

@ViewBuilder
fileprivate func createTextView(_ text: String) -> some View {
    Text(text).font(.system(size: 16)).padding([.bottom], 16).padding([.leading, .trailing], 8)
}

struct ViewRulesView: View {
    @ObservedObject private var _dm = DataManager.shared

    @State var searchText: String = ""
    let rulebook: Rulebook?

    var body: some View {
        GeometryReader { gr in
            VStack {
                Text("Rulebook v\(rulebook?.version ?? "unknown version")")
                    .font(.system(size: 32, weight: .bold))
                    .frame(alignment: .center)
                TextField("Search", text: $searchText)
                    .padding([.leading, .trailing], 16)
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
        let st = searchText.trimmed
        return (st.isEmpty ? rulebook?.headings : rulebook?.headings.filter({ $0.contains(st) })) ?? []
    }

}

struct HeadingView: View {
    @ObservedObject private var _dm = DataManager.shared

    let heading: Heading
    let width: CGFloat

    var body: some View {
        BlackCardView2pxPadding {
            VStack {
                Text(heading.title)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                ForEach(0 ..< heading.textsAndTables.count, id: \.self) { index in
                    if let table = heading.textsAndTables[index] as? Table {
                        TableView(table: table, width: width)
                            .padding(.leading, 2)
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
    @ObservedObject private var _dm = DataManager.shared

    let subHeading: SubHeading
    let width: CGFloat

    var body: some View {
        VStack {
            Text(subHeading.title)
                .multilineTextAlignment(.leading)
                .font(.system(size: 28))
                .italic()
                .fontWeight(.bold)
            ForEach(0 ..< subHeading.textsAndTables.count, id: \.self) { index in
                if let table = subHeading.textsAndTables[index] as? Table {
                    TableView(table: table, width: width)
                        .padding(.leading, 2)
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
    @ObservedObject private var _dm = DataManager.shared

    let subSubHeading: SubSubHeading
    let width: CGFloat

    var body: some View {
        VStack {
            Text(subSubHeading.title)
                .multilineTextAlignment(.leading)
                .font(.system(size: 24))
                .italic()
                .underline()
                .fontWeight(.bold)
            ForEach(0 ..< subSubHeading.textsAndTables.count, id: \.self) { index in
                if let table = subSubHeading.textsAndTables[index] as? Table {
                    TableView(table: table, width: width)
                        .padding([.leading, .bottom], 4)
                } else if let text = subSubHeading.textsAndTables[index] as? String {
                    createTextView(text)
                }
            }
        }
    }
}

struct TableView: View {
    @ObservedObject private var _dm = DataManager.shared

    let table: Table
    let width: CGFloat

    var body: some View {
        ScrollView(.horizontal) {
            ForEach(table.convertToRows(), id:\.self) { column in
                BlackBorder {
                    HStack {
                        ForEach(0 ..< column.count, id:\.self) { index in
                            HStack {
                                Spacer()
                                if index == 0 {
                                    Text(column[index]).font(.system(size: 16)).bold().frame(width: width * 0.4).fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.center)
                                } else {
                                    Text(column[index]).font(.system(size: 16)).frame(width: width * 0.4).fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                            }
                        }
                    }.padding([.top, .bottom], 8)
                }
            }
        }
    }
}



#Preview {
    ViewRulesView(rulebook: Rulebook(version: "1.0.0"))
}
