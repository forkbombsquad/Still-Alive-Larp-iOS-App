//
//  CGRectExtensions.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/16/25.
//

import Foundation

extension CGRect {
    
    func contains(x: CGFloat, y: CGFloat) -> Bool {
        return self.contains(CGPoint(x: x, y: y))
    }
    
    func center() -> CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    
}
