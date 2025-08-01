//
//  LoadingLayoutView.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 8/1/25.
//

import SwiftUI

struct LoadingLayoutView<Content: View>: View {
    @Binding var isLoading: Bool
    @Binding var loadingText: String
    let content: () -> Content
    
    var body: some View {
        Group {
            if isLoading {
                LoadingLayout(loadingText: $loadingText)
            } else {
                content()
            }
        }
    }
}

struct LoadingLayout: View {
    @Binding var loadingText: String
    
    var body: some View {
        CardView {
            Text("Getting Content...")
                .frame(alignment: .center)
                .font(.system(size: 24, weight: .bold))
                .padding(8)
            Text(loadingText)
                .frame(alignment: .center)
                .font(.system(size: 18))
                .padding([.bottom, .horizontal], 8)
            ProgressView()
        }
    }
}

#Preview {
    LoadingLayout(loadingText: .constant("Players, Characters, Profile Images"))
}
