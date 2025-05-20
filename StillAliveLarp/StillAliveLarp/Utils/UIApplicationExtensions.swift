//
//  UIApplicationExtensions.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/28/23.
//

import Foundation
import UIKit

extension UIApplication {

    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

}
