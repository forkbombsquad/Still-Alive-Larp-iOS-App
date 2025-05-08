//
//  LoadingButtonView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/15/23.
//

import SwiftUI

struct LoadingButtonView: View {
    @ObservedObject var _dm = DataManager.shared

    init(_ loading: Binding<Bool>, loadingText: Binding<String> = .init(get: {return ""}, set: {_ in}), width: CGFloat, height: CGFloat = 90, buttonText: String, progressViewOffset: CGFloat = 0, onButtonPress: @escaping () -> Void) {
        self._loading = loading
        self.width = width
        self.height = height
        self.buttonText = buttonText
        self.progressViewOffest = progressViewOffset
        self.onButtonPress = onButtonPress
        self._loadingText = loadingText
    }

    @Binding var loading: Bool

    @Binding var loadingText: String

    let width: CGFloat
    let height: CGFloat
    let buttonText: String
    let progressViewOffest: CGFloat
    let onButtonPress: () -> Void

    var body: some View {
        Button(action: {
            guard !loading else { return }
            UIApplication.shared.dismissKeyboard()
            onButtonPress()
        }, label: {
            Text(buttonText)
                .frame(width: width, height: height)
            })
            .overlay(content: {
                if loading {
                    HStack {
                        ProgressView()
                        .tint(.white)
                        .padding(.top, progressViewOffest)
                        if !loadingText.isEmpty {
                            Text(" \(loadingText) ").foregroundColor(.white)
                            ProgressView()
                            .tint(.white)
                            .padding(.top, progressViewOffest)
                        }
                    }
                } else {
                    EmptyView()
                }
            })
            .foregroundColor(loading ? .midRed : .white)
            .buttonStyle(.borderedProminent)
            .tint(Color.midRed)
    }
}

struct FakeLoadingButtonView: View {
    @ObservedObject var _dm = DataManager.shared

    init(_ loading: Binding<Bool>, loadingText: Binding<String> = .init(get: {return ""}, set: {_ in}), width: CGFloat, height: CGFloat = 90, buttonText: String, progressViewOffset: CGFloat = 0) {
        self._loading = loading
        self.width = width
        self.height = height
        self.buttonText = buttonText
        self.progressViewOffest = progressViewOffset
        self._loadingText = loadingText
    }

    @Binding var loading: Bool

    @Binding var loadingText: String

    let width: CGFloat
    let height: CGFloat
    let buttonText: String
    let progressViewOffest: CGFloat

    var body: some View {
        Button(action: {}, label: {
            Text(buttonText)
                .frame(width: width, height: height)
            })
            .overlay(content: {
                if loading {
                    HStack {
                        ProgressView()
                        .tint(.white)
                        .padding(.top, progressViewOffest)
                        if !loadingText.isEmpty {
                            Text(" \(loadingText) ").foregroundColor(.white)
                            ProgressView()
                            .tint(.white)
                            .padding(.top, progressViewOffest)
                        }
                    }
                } else {
                    EmptyView()
                }
            })
            .foregroundColor(loading ? .midRed : .white)
            .buttonStyle(.borderedProminent)
            .tint(Color.midRed)
            .allowsHitTesting(false)
    }
}

#Preview {
    LoadingButtonView(.constant(false), loadingText: .constant(""), width: 200, height: 44, buttonText: "BUTTON", progressViewOffset: 0) {
        //
    }
}
