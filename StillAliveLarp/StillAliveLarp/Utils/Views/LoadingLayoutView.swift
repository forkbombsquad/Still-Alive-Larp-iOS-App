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
    
    @State private var lastAppearTime: Date? = nil
    
    let loadType: DataManager.DataManagerLoadType
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
        ZStack {
            content()
                .opacity(DM.isLoadingMirror ? 0 : 1)
                .disabled(DM.isLoadingMirror) // prevent interactions while loading
            
            if DM.isLoadingMirror {
                LoadingLayout()
            }
        }.onAppear {
            // Ran into a race condition where changing published variables caused the onAppear to be called too quickly so it would loop endlessly. Restricting it to once per second fixes the issue
            let now = Date()
            if let lastTime = lastAppearTime,
               now.timeIntervalSince(lastTime) < 1 {
                return
            }

            lastAppearTime = now

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
