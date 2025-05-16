//
//  LoadingBlock.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/16/25.
//

import SwiftUI

// TODO use this everywhere

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

#Preview {
    LoadingBlock()
}
