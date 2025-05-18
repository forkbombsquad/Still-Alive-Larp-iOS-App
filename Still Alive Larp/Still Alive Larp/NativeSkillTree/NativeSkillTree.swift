//
//  NativeSkillTree.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/16/25.
//
import SwiftUI

// TODO this view is super broken but its like 40% of the way there lol. Work on it

struct NativeSkillTree: View {
    
    private let collapsedWidth: CGFloat = 200
    private let expandedWidth: CGFloat = 350
    
    private let tapThreshold: CGFloat = 10
    
    private let vertPadding: CGFloat = 16
    private let horPadding: CGFloat = 16
    
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    @State private var lastDragValue: CGSize = .zero
    
    @State private var skillSizes: [Int: CGSize] = [:]
    @State private var tallestHeightRows: [Int: CGFloat] = [:]
    
    @GestureState private var pinchAnchor: CGPoint? = nil

    let skillGrid: SkillGrid

    @State var expanded = false
    
    var body: some View {
        ZStack {
            Canvas { context, size in
                context.translateBy(x: currentOffset.width, y: currentOffset.height)
                context.scaleBy(x: currentScale, y: currentScale)
                
                for gridSkill in skillGrid.trueGrid {
                    
                    if let symbol = context.resolveSymbol(id: gridSkill.skill.id) {
                        let gridX = gridSkill.gridX.cgFloat
                        let gridY = gridSkill.gridY.cgFloat
                        
                        let skill = gridSkill.skill
                        let size = skillSizes[skill.id] ?? .zero
                        let width = expanded ? expandedWidth : collapsedWidth
                        
                        var x = gridX * width
                        x += (gridX * horPadding)
                        
                        let index = max(skill.xpCost.intValueDefaultZero - 1, 0)
                        var y = gridY * ((tallestHeightRows[index] ?? 0) * 2)
                        y += (gridY * vertPadding * 2)
                        if gridSkill.lowered {
                            y += (tallestHeightRows[index] ?? 0)
                            y += vertPadding
                        }
                        
                        context.draw(symbol, in: CGRect(x: x, y: y, width: width, height: size.height))
                    }
                }
            } symbols: {
                ForEach(skillGrid.skills) { skill in
                    CanvasSkillCell(expanded: expanded, skill: skill, allowPurchase: true, purchaseState: .purchased, loadingPurchase: false, collapsedWidth: collapsedWidth, expandedWidth: expandedWidth)
                }
            }
            .gesture(dragGesture
                .simultaneously(with: magnificationGesture))
            .background(Color.black)
            
            
        }.background {
            // Hidden views for measurements
            VStack {
                ForEach(skillGrid.skills) { skill in
                    SkillCellMeasurer(skill: skill, expanded: expanded, allowPurchase: true, purchaseState: .purchased, loadingPurchase: false, collapsedWidth: collapsedWidth, expandedWidth: expandedWidth)
                }
            }
            .hidden()
            .onPreferenceChange(SkillSizePreferenceKey.self) { sizes in
                skillSizes = sizes
                calcTallestHeightRows()
            }
        }
    }

    private func calcTallestHeightRows() {
        for skill in skillGrid.skills {
            let size = skillSizes[skill.id] ?? .zero
            let index = max(skill.xpCost.intValueDefaultZero - 1, 0)
            if tallestHeightRows[index] == nil || tallestHeightRows[index] ?? 0 > size.height {
                tallestHeightRows[index] = size.height
            }
        }
    }

    /// Pan / drag
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                currentOffset = CGSize(
                    width: lastDragValue.width + value.translation.width,
                    height: lastDragValue.height + value.translation.height
                )
            }
            .onEnded { value in
                // store final
                if tapThreshold >= hypot(value.translation.width, value.translation.height) {
                    currentOffset = lastDragValue
                    
                    let tapX = (value.location.x - currentOffset.width) / currentScale
                    let tapY = (value.location.y - currentOffset.height) / currentScale
                    self.handleTap(x: tapX, y: tapY)
                } else {
                    lastDragValue = currentOffset
                }
                
            }
    }

    /// Pinch / zoom
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .updating($pinchAnchor) { _, state, transaction in
                // no-op for now
            }
            .onChanged { newScale in
                let delta = newScale / lastScaleValue
                lastScaleValue = newScale

                // Compute zoom around anchor point (as discussed earlier)
                let anchorInView = CGPoint(x: 200, y: 200) // Or dynamic if available
                let anchorX = (anchorInView.x - currentOffset.width) / currentScale
                let anchorY = (anchorInView.y - currentOffset.height) / currentScale
                let anchorInCanvas = CGPoint(x: anchorX, y: anchorY)

                currentScale = (currentScale * delta).clamped(to: 0.1...100)

                currentOffset = CGSize(
                    width: anchorInCanvas.x * -currentScale + anchorInView.x,
                    height: anchorInCanvas.y * -currentScale + anchorInView.y
                )

                // 🔧 Sync drag anchor to prevent jumps
                lastDragValue = currentOffset
            }
            .onEnded { _ in
                lastScaleValue = 1.0
            }
    }
    
    private func handleTap(x: CGFloat, y: CGFloat) {
        // TODO handle tap
        self.expanded.toggle()
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

