//
//  LoadingLayoutView.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 8/1/25.
//

import SwiftUI

struct LoadingLayoutView<Content: View>: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    let loadType: DataManager.DataManagerLoadType = .downloadIfNecessary
    let onStepFinished: () -> Void
    let onFinishedLoad: () -> Void
    let content: () -> Content
    
    init(loadType: DataManager.DataManagerLoadType = .downloadIfNecessary, onStepFinished: @escaping () -> Void = {}, onFinishedLoad: @escaping () -> Void = {}, content: @escaping () -> Content) {
        self.loadType = loadType
        self.onStepFinished = onStepFinished
        self.onFinishedLoad = onFinishedLoad
        self.content = content
    }
    
    var body: some View {
        Group {
            if DM.isLoadingMirror {
                LoadingLayout()
            } else {
                content()
            }
        }.onAppear {
            DM.load(loadType: loadType) {
                onStepFinished()
            } finished: {
                onFinishedLoad()
            }
        }
    }
}

struct LoadingLayout: View {
    
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager
    
    var body: some View {
        CardView {
            Text("Getting Content...")
                .frame(alignment: .center)
                .font(.system(size: 24, weight: .bold))
                .padding(8)
            Text(DM.loadingText)
                .frame(alignment: .center)
                .font(.system(size: 18))
                .padding([.bottom, .horizontal], 8)
            ProgressView()
        }
    }
}

#Preview {
    LoadingLayout()
}
