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
    private let expandedWidth: CGFloat = 300
    
    private let tapThreshold: CGFloat = 10
    
    private let vertPadding: CGFloat = 64
    private let horPadding: CGFloat = 64
    
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    @State private var lastDragValue: CGSize = .zero
    
    @State private var skillSizes: [Int: CGSize] = [:]
    @State private var tallestHeightRows: [Int: CGFloat] = [:]
    @State private var expandedSkill: GridSkill? = nil
    
    @GestureState private var pinchAnchor: CGPoint? = nil

    let skillGrid: SkillGrid

    @State var trueGrid: [GridSkill]
    
    init(skillGrid: SkillGrid) {
        self.skillGrid = skillGrid
        self._trueGrid = globalState(skillGrid.trueGrid)
    }
    
    var body: some View {
        ZStack {
            Canvas { context, size in
                context.translateBy(x: currentOffset.width, y: currentOffset.height)
                context.scaleBy(x: currentScale, y: currentScale)
                
                let exSkill = expandedSkill
                let xEx = exSkill?.gridX ?? 999999
                let yEx = exSkill?.gridY ?? 999999
                
                for gridSkill in trueGrid.sorted(by: { $0.skill.skillCategoryId < $1.skill.skillCategoryId }) {
                    
                    if let symbol = context.resolveSymbol(id: gridSkill.skill.id) {
                        
                        let width = gridSkill.expanded ? expandedWidth : collapsedWidth
                        let size = skillSizes[gridSkill.skill.id] ?? .zero
                        context.draw(symbol, in: CGRect(x: getGridX(gridSkill, xEx), y: getGridY(gridSkill, yEx), width: width, height: size.height))
                    }
                }
                
                var heightDelta: CGFloat = 0
                if let exSkill = expandedSkill {
                    let expandedHeight = skillSizes[exSkill.skill.id]?.height ?? 0
                    let index = max(exSkill.skill.xpCost.intValueDefaultZero - 1, 0)
                    let baseHeight = tallestHeightRows[index] ?? 0
                    heightDelta = expandedHeight - baseHeight
                }
                let exSkillCat = expandedSkill?.skill.skillCategoryId ?? 999999
                var prevX: CGFloat = 0
                for gridCategory in skillGrid.gridCategories.sorted(by: { $0.skillCategoryId < $1.skillCategoryId }) {
                    let w = gridCategory.width.cgFloat
                    var x = prevX
                    x += w * collapsedWidth
                    x += horPadding * (w + 1)
                    if exSkillCat <= gridCategory.skillCategoryId {
                        x += expandedWidth - collapsedWidth
                    }
                    
                    var y = 8 * collapsedWidth
                    y += 12 * vertPadding
                    y += heightDelta
                    
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: -vertPadding * 3))
                    path.addLine(to: CGPoint(x: x, y: y))
                    context.stroke(path, with: .color(.white), style: StrokeStyle(lineWidth: 5))
                    prevX = x
                }
                
                
                var path = Path()
                path.move(to: CGPoint(x: 0, y: -vertPadding))
                path.addLine(to: CGPoint(x: 99999, y: -vertPadding))
                context.stroke(path, with: .color(.white), style: StrokeStyle(lineWidth: 5))
                
                context.stroke(getHorizontalDashedLinePath(1), with: .color(.white), style: StrokeStyle(lineWidth: 5, dash: [16, 5]))
                context.stroke(getHorizontalDashedLinePath(2), with: .color(.white), style: StrokeStyle(lineWidth: 5, dash: [16, 5]))
                context.stroke(getHorizontalDashedLinePath(3), with: .color(.white), style: StrokeStyle(lineWidth: 5, dash: [16, 5]))
                context.stroke(getHorizontalDashedLinePath(4), with: .color(.white), style: StrokeStyle(lineWidth: 5, dash: [16, 5]))
            } symbols: {
                ForEach(trueGrid) { skill in
                    CanvasSkillCell(expanded: skill.expanded, skill: skill.skill, allowPurchase: true, purchaseState: .purchased, loadingPurchase: false, collapsedWidth: collapsedWidth, expandedWidth: expandedWidth)
                }
            }
            .gesture(dragGesture
                .simultaneously(with: magnificationGesture))
            .background(Color.black)
            
            
        }.background {
            // Hidden views for measurements
            VStack {
                ForEach(trueGrid) { skill in
                    SkillCellMeasurer(skill: skill.skill, expanded: skill.expanded, allowPurchase: true, purchaseState: .purchased, loadingPurchase: false, collapsedWidth: collapsedWidth, expandedWidth: expandedWidth)
                }
            }
            .hidden()
            .onPreferenceChange(SkillSizePreferenceKey.self) { sizes in
                skillSizes = sizes
                calcTallestHeightRows()
                self.forceRefresh()
            }
        }
    }
    
    private func getHorizontalDashedLinePath(_ lineNum: Int) -> Path {
        var y = ((tallestHeightRows[lineNum - 1] ?? 0) * 2 * lineNum.cgFloat)
        y += (vertPadding * 3 * lineNum.cgFloat)
        if let exSkill = expandedSkill {
            let expandedHeight = skillSizes[exSkill.skill.id]?.height ?? 0
            let index = max(exSkill.skill.xpCost.intValueDefaultZero - 1, 0)
            let baseHeight = tallestHeightRows[index] ?? 0
            let heightDelta = expandedHeight - baseHeight

            let yEx = expandedSkill?.gridY ?? 999999
            if lineNum > yEx {
                y += heightDelta
            }
        }
        var path = Path()
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: 99999, y: y))
        return path
    }
    
    private func forceRefresh() {
        DispatchQueue.main.async {
            self.trueGrid = trueGrid
        }
    }
    
    private func getTappedOnSkill(x: CGFloat, y: CGFloat) -> Int? {
        return skillGrid.trueGrid.firstIndex(where: { getHitRect($0).contains(x: x, y: y) })
    }
    
    private func tappedOnPurchase(_ gridSkill: GridSkill, x: CGFloat, y: CGFloat) -> Bool {
        // TODO this isn't working
//        // height 90
//        // padding 32
//        let height = skillSizes[gridSkill.skill.id]?.height ?? 0
//        let buttonHeight: CGFloat = 90
//        let buttonWidth: CGFloat = expandedWidth - 64
//        let buttonXOffset: CGFloat = 32
//        let buttonYOffset: CGFloat = 32
//        let x = getGridX(gridSkill, gridSkill.gridX)
//        let y = getGridY(gridSkill, gridSkill.gridY)
//        
//        let rect = CGRect(x: x + buttonXOffset, y: y - buttonYOffset - buttonHeight + height, width: buttonWidth, height: buttonHeight)
//        globalTestPrint("FFFFFF \(rect.contains(x: x, y: y))")
//        return rect.contains(x: x, y: y)
        return false
    }
    
    private func getHitRect(_ gridSkill: GridSkill) -> CGRect {
        let xEx = self.expandedSkill?.gridX ?? 99999
        let yEy = self.expandedSkill?.gridY ?? 99999
        let width = gridSkill.expanded ? expandedWidth : collapsedWidth
        let index = max(gridSkill.skill.xpCost.intValueDefaultZero - 1, 0)
        let height = tallestHeightRows[index] ?? 0
        return CGRect(x: getGridX(gridSkill, xEx), y: getGridY(gridSkill, yEy), width: width, height: height)
    }
    
    private func getGridX(_ gridSkill: GridSkill, _ xEx: Int) -> CGFloat {
        let gridX = gridSkill.gridX.cgFloat
        let width = collapsedWidth
        var x = gridX * width
        x += (gridX * horPadding)
        if gridSkill.gridX > xEx {
            x += expandedWidth - collapsedWidth
        }
        x += horPadding * gridSkill.skill.skillCategoryId.cgFloat
        return x
    }
    
    private func getGridY(_ gridSkill: GridSkill, _ yEx: Int) -> CGFloat {
        let gridY = gridSkill.gridY.cgFloat
        let index = max(gridSkill.skill.xpCost.intValueDefaultZero - 1, 0)
        var y = gridY * ((tallestHeightRows[index] ?? 0) * 2)
        y += (gridY * vertPadding * 3)
        y += vertPadding
        if gridSkill.lowered {
            y += (tallestHeightRows[index] ?? 0)
            y += vertPadding
        }
        if let exSkill = expandedSkill {
            let expandedHeight = skillSizes[exSkill.skill.id]?.height ?? 0
            let index = max(exSkill.skill.xpCost.intValueDefaultZero - 1, 0)
            let baseHeight = tallestHeightRows[index] ?? 0
            let heightDelta = expandedHeight - baseHeight

            if gridSkill.gridY > yEx || (gridSkill.lowered && exSkill.lowered == false) {
                y += heightDelta
            }
        }
        return y
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
        if let tappedSkillIndex = getTappedOnSkill(x: x, y: y) {
            if trueGrid[tappedSkillIndex].expanded, tappedOnPurchase(trueGrid[tappedSkillIndex], x: x, y: y) {
                // TODO purchase
            } else {
                let oldState = trueGrid[tappedSkillIndex].expanded
                for index in trueGrid.indices {
                    trueGrid[index].expanded = false
                }
                trueGrid[tappedSkillIndex].expanded = !oldState
                self.expandedSkill = !oldState ? trueGrid[tappedSkillIndex] : nil
                
                forceRefresh()
            }
        } else {
            for index in trueGrid.indices {
                trueGrid[index].expanded = false
            }
            self.expandedSkill = nil
            forceRefresh()
        }
    }

}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

