//
//  StyledPickerView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/12/25.
//

import SwiftUI

struct StyledPickerView: View {
    
    @Binding var title: String
    @Binding var selection: String
    @Binding var options: [String]
    let onSelectionChanged: (_ selection: String) -> Void
    
    init(title: String, selection: Binding<String>, options: [String], onSelectionChanged: @escaping (_ selection: String) -> Void) {
        _title = .constant(title)
        _selection = selection
        _options = .constant(options)
        self.onSelectionChanged = onSelectionChanged
    }
    
    init(title: Binding<String>, selection: Binding<String>, options: Binding<[String]>, onSelectionChanged: @escaping (_ selection: String) -> Void) {
        _title = title
        _selection = selection
        _options = options
        self.onSelectionChanged = onSelectionChanged
    }
    
    var body: some View {
        CardView {
            VStack {
                Text(title)
                    .font(.system(size: 24))
                    .padding(.horizontal, 8)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Menu {
                    ForEach(options, id: \.self) { option in
                        Button(option) {
                            selection = option
                            self.onSelectionChanged(option)
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text(selection)
                            .foregroundColor(.midRed)
                            .font(.system(size: 24, weight: .bold))
                        Image(systemName: "chevron.down")
                            .foregroundStyle(Color.midRed)
                            .font(.system(size: 24, weight: .bold))
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    StyledPickerView(title: .constant("Title"), selection: .constant("First Option"), options: .constant(["First Option", "Second Option", "Third Option"])) { _ in }
}
