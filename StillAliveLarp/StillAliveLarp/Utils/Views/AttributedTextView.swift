//
//  AttributedTextView.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 8/6/25.
//

import SwiftUI

struct AttributedTextView: UIViewRepresentable {
    let attributedString: NSAttributedString

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = attributedString
    }
}
