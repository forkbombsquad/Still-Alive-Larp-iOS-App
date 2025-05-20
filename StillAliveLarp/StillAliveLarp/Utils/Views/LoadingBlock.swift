//
//  LoadingBlock.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/16/25.
//

import SwiftUI

struct LoadingBlock: View {
    var body: some View {
        HStack {
            Spacer()
            ProgressView()
                .controlSize(.large)
                .tint(.midRed)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct LoadingBlockWithText: View {
    
    @Binding var loadingText: String
    
    var body: some View {
        HStack {
            if loadingText.isNotEmpty {
                ProgressView()
                    .controlSize(.large)
                    .tint(.midRed)
                    .padding(.leading, 8)
                Text(loadingText)
                    .font(.system(size: 24))
                    .foregroundStyle(Color.midRed)
                    .multilineTextAlignment(.center)
                    .frame(alignment: .center)
                    .padding(.horizontal, 8)
                ProgressView()
                    .controlSize(.large)
                    .tint(.midRed)
                    .padding(.trailing, 8)
            } else {
                Spacer()
                ProgressView()
                    .controlSize(.large)
                    .tint(.midRed)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    LoadingBlockWithText(loadingText: .constant("A long boi with multiple lines\nI told you\n\n\nIt's a biggun"))
}
