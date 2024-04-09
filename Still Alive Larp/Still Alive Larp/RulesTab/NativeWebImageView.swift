//
//  NativeWebImageView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/17/23.
//

import SwiftUI
import WebKit

struct NativeWebImageView: UIViewRepresentable {

    let request: URLRequest

    func makeUIView(context: Context) -> some UIView {
        return WKWebView()
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        (uiView as? WKWebView)?.load(request)
    }

}
