//
//  ViewExtensions.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/14/23.
//

import Foundation
import SwiftUI

extension View {

    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            ZStack(alignment: alignment) {
                self
                placeholder().opacity(shouldShow ? 1 : 0).allowsHitTesting(false)
            }
    }

}
