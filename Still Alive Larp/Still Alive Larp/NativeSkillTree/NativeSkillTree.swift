//
//  NativeSkillTree.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/16/25.
//
import SwiftUI

// TODO this view is super broken but its like 40% of the way there lol. Work on it

struct SkillTreeView: View {
    // MARK: – Drawing state
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    @State private var lastDragValue: CGSize = .zero

    let skillGrid: SkillGrid

    var body: some View {
        // Use SwiftUI’s Canvas for custom drawing
        Canvas { context, size in
            // Apply current transform
            context.translateBy(x: currentOffset.width, y: currentOffset.height)
            context.scaleBy(x: currentScale, y: currentScale)

            // Delegate all drawing to your SkillGrid
            skillGrid.draw(in: context, size: size)
        }
        .gesture(dragGesture
                    .simultaneously(with: magnificationGesture)
                    .simultaneously(with: tapGesture))
        .onChange(of: currentScale) { _ in
            // If your grid needs to react to scale‑changes
            skillGrid.invalidate()
        }
        .onChange(of: currentOffset) { _ in
            // Likewise for panning
            skillGrid.invalidate()
        }
    }

    // MARK: – Gestures

    /// Pan / drag
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                currentOffset = CGSize(
                    width: lastDragValue.width + value.translation.width,
                    height: lastDragValue.height + value.translation.height
                )
            }
            .onEnded { _ in
                // store final
                lastDragValue = currentOffset
            }
    }

    /// Pinch / zoom
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { newScale in
                // Combine with last saved scale
                let delta = newScale / lastScaleValue
                currentScale = (currentScale * delta)
                  .clamped(to: 0.1...100)   // same limits as Android
                lastScaleValue = newScale
            }
            .onEnded { _ in
                lastScaleValue = 1.0
            }
    }

    private var tapGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onEnded { value in

                let transformedX = (value.location.x - currentOffset.width) / currentScale
                let transformedY = (value.location.y - currentOffset.height) / currentScale

                skillGrid.handleTap(x: transformedX, y: transformedY)
                skillGrid.invalidate()
            }
    }

}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

struct SkillGridConstants {
    let skillWidth: CGFloat = 300
    let skillWidthExpanded: CGFloat = 600
    let skillHeight: CGFloat = 300
    let spacingWidth: CGFloat = 75
    let spacingHeight: CGFloat = 150
    let xpCostWidth: CGFloat = 450
    let titleSize: CGFloat = 60
    let titleSpacing: CGFloat = 20
}

