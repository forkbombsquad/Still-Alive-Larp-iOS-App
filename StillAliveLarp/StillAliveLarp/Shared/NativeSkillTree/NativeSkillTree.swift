//
//  NativeSkillTree.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 5/16/25.
//
import SwiftUI

struct NativeSkillTree: View {
    
    static func initAsBase(allSkills: [FullCharacterModifiedSkillModel], currentPlayer: FullPlayerModel) -> NativeSkillTree {
        return NativeSkillTree(allSkills: allSkills, personal: false, allowPurchase: false, player: currentPlayer, character: nil)
    }
    
    static func initAsPersonal(currentPlayer: FullPlayerModel, character: FullCharacterModel, isInOfflineMode: Bool) -> NativeSkillTree {
        return NativeSkillTree(allSkills: [], personal: true, allowPurchase: !isInOfflineMode, player: currentPlayer, character: character)
    }
    
    static func initAsPlannedPersonal(currentPlayer: FullPlayerModel, plannedCharacter: FullCharacterModel, isInOfflineMode: Bool) -> NativeSkillTree {
        return NativeSkillTree(allSkills: [], personal: true, allowPurchase: !isInOfflineMode, player: currentPlayer, character: plannedCharacter)
    }
    
    static func initAsOtherPlayerPersonal(currentPlayer: FullPlayerModel, character: FullCharacterModel) -> NativeSkillTree {
        return NativeSkillTree(allSkills: [], personal: true, allowPurchase: false, player: currentPlayer, character: character)
    }
    
    static func initAsNPCPersonal(currentPlayer: FullPlayerModel, npc: FullCharacterModel) -> NativeSkillTree {
        return NativeSkillTree(allSkills: [], personal: true, allowPurchase: false, player: currentPlayer, character: npc)
    }
    
    
    private let collapsedWidth: CGFloat = 300
    private let expandedWidth: CGFloat = 500
    
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
    
    @State private var isPurchasing: Bool = false
    @State private var loadingText: String = "Puchasing..."
    
    @GestureState private var pinchAnchor: CGPoint? = nil

    @StateObject var skillGrid: SkillGrid
    @State var availableSkills: [FullCharacterModifiedSkillModel] = []
    
    private init(allSkills: [FullCharacterModifiedSkillModel], personal: Bool, allowPurchase: Bool, player: FullPlayerModel, character: FullCharacterModel?) {
        self._skillGrid = globalStateObject(SkillGrid(personal: personal, allowPurchase: allowPurchase, player: player, character: character, skills: allSkills))
        self.availableSkills = character?.allPurchaseableSkills() ?? []
    }
    
    var body: some View {
        ZStack {
            Canvas { context, size in
                context.translateBy(x: currentOffset.width, y: currentOffset.height)
                context.scaleBy(x: currentScale, y: currentScale)
                drawConnectionLines(context)
                drawSkills(context)
                let finalX = drawCategories(context)
                drawLines(context, finalX: finalX)
            } symbols: {
                ForEach(skillGrid.trueGrid) { skill in
                    let skillIsPurchased: Bool = skillGrid.character == nil ? true : skillGrid.character!.allPurchasedSkills().contains(where: { $0.id == skill.skill.id })
                    let skillCouldBePurchased = (skillGrid.character == nil ? false : availableSkills.contains(where: { $0.id == skill.skill.id })) && skillGrid.allowPurchase
                    CanvasSkillCell(expanded: skill.expanded, skill: skill.skill, allowPurchase: !skillIsPurchased && skillCouldBePurchased, purchaseState: skillIsPurchased ? .purchased : (skillCouldBePurchased ? .couldPurchase : .cantPurchase), loadingPurchase: self.isPurchasing, collapsedWidth: collapsedWidth, expandedWidth: expandedWidth, loadingText: loadingText)
                }
            }
            .gesture(dragGesture
                .simultaneously(with: magnificationGesture))
            .background(Color.black)
            .onAppear {
                currentScale = 0.2
            }

        }.background {
            // Hidden views for measurements
            VStack {
                ForEach(skillGrid.trueGrid) { skill in
                    let skillIsPurchased: Bool = skillGrid.character == nil ? true : skillGrid.character!.allPurchasedSkills().contains(where: { $0.id == skill.skill.id })
                    let skillCouldBePurchased = (skillGrid.character == nil ? false : availableSkills.contains(where: { $0.id == skill.skill.id })) && skillGrid.allowPurchase
                    SkillCellMeasurer(skill: skill.skill, expanded: skill.expanded, allowPurchase: !skillIsPurchased && skillCouldBePurchased, purchaseState: skillIsPurchased ? .purchased : (skillCouldBePurchased ? .couldPurchase : .cantPurchase), loadingPurchase: self.isPurchasing, collapsedWidth: collapsedWidth, expandedWidth: expandedWidth)
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
    
    private func drawConnectionLines(_ context: SwiftUICore.GraphicsContext) {
        let exSkill = expandedSkill
        let exXpCost = exSkill?.skill.baseXpCost() ?? 0
        let exId = exSkill?.skill.id ?? -1
        let xEx = exSkill?.gridX ?? 999999
        let yEx = exSkill?.gridY ?? 999999
        
        for gridSkill in skillGrid.trueGrid.sorted(by: { $0.skill.category.id < $1.skill.category.id }) {
            if gridSkill.skill.prereqs().isNotEmpty {
                for prereq in gridSkill.skill.prereqs() {
                    if let pr = skillGrid.trueGrid.first(where: { $0.skill.id == prereq.id }) {
                        
                        let startXOffset = ((prereq.id == exId) ? expandedWidth : collapsedWidth) / 2
                        
                        let expandedHeight = skillSizes[exId]?.height ?? 0
                        let index = max(exXpCost - 1, 0)
                        let baseHeight = tallestHeightRows[index] ?? 0
                        
                        let startYOffset = (prereq.id == exId) ? expandedHeight : baseHeight
                        let endXOffset = ((gridSkill.skill.id == exId) ? expandedWidth : collapsedWidth) / 2
                        var path = Path()
                        path.move(to: CGPoint(x: getGridX(pr, xEx) + startXOffset, y: getGridY(pr, yEx) + startYOffset))
                        path.addLine(to: CGPoint(x: getGridX(gridSkill, xEx) + endXOffset, y: getGridY(gridSkill, yEx)))
                        
                        
                        context.stroke(path, with: .color(.white), style: StrokeStyle(lineWidth: 5))
                    }
                }
            }
            
            if let symbol = context.resolveSymbol(id: gridSkill.skill.id) {
                
                let width = gridSkill.expanded ? expandedWidth : collapsedWidth
                let size = skillSizes[gridSkill.skill.id] ?? .zero
                context.draw(symbol, in: CGRect(x: getGridX(gridSkill, xEx), y: getGridY(gridSkill, yEx), width: width, height: size.height))
            }
        }
    }
    
    private func drawSkills(_ context: SwiftUICore.GraphicsContext) {
        let exSkill = expandedSkill
        let xEx = exSkill?.gridX ?? 999999
        let yEx = exSkill?.gridY ?? 999999
        
        for gridSkill in skillGrid.trueGrid.sorted(by: { $0.skill.category.id < $1.skill.category.id }) {
            
            if let symbol = context.resolveSymbol(id: gridSkill.skill.id) {
                
                let width = gridSkill.expanded ? expandedWidth : collapsedWidth
                let size = skillSizes[gridSkill.skill.id] ?? .zero
                context.draw(symbol, in: CGRect(x: getGridX(gridSkill, xEx), y: getGridY(gridSkill, yEx), width: width, height: size.height))
            }
        }
    }
    
    private func drawCategories(_ context: SwiftUICore.GraphicsContext) -> CGFloat {
        
        var heightDelta: CGFloat = 0
        if let exSkill = expandedSkill {
            let expandedHeight = skillSizes[exSkill.skill.id]?.height ?? 0
            let index = max(exSkill.skill.baseXpCost() - 1, 0)
            let baseHeight = tallestHeightRows[index] ?? 0
            heightDelta = expandedHeight - baseHeight
        }
        let exSkillCat = expandedSkill?.skill.category.id ?? 999999
        var prevX: CGFloat = 0
        for gridCategory in skillGrid.gridCategories {
            let w = gridCategory.width.cgFloat
            var x = prevX
            x += w * collapsedWidth
            x += horPadding * (w + 1)
            if exSkillCat == gridCategory.skillCategoryId {
                x += expandedWidth - collapsedWidth
            }
            
            var y = 8 * collapsedWidth
            y += 12 * vertPadding
            y += heightDelta
            
            var path = Path()
            path.move(to: CGPoint(x: x, y: -vertPadding * 3))
            path.addLine(to: CGPoint(x: x, y: y))
            context.stroke(path, with: .color(.white), style: StrokeStyle(lineWidth: 5))
            
            let text = Text(gridCategory.skillCategoryName).font(.system(size: 50, weight: .bold)).foregroundColor(.white)

            let labelRect = CGRect(x: prevX, y: -vertPadding * 3, width: x - prevX, height: vertPadding * 3)
            let centerPoint = CGPoint(x: labelRect.midX, y: labelRect.midY)

            context.draw(text, at: centerPoint, anchor: .center)
            
            if gridCategory.skillCategoryId == -1 {
                drawXpDiamonds(context, xLoc: prevX)
            }
            
            prevX = x
        }
        return prevX
    }
    
    private func drawXpDiamonds(_ context: SwiftUICore.GraphicsContext, xLoc: CGFloat) {
        var prevY: CGFloat = -vertPadding
        for diamondNum in 1..<5 {
            var y = ((tallestHeightRows[diamondNum - 1] ?? 0) * 2 * diamondNum.cgFloat)
            y += (vertPadding * 3 * diamondNum.cgFloat)
            if let exSkill = expandedSkill {
                let expandedHeight = skillSizes[exSkill.skill.id]?.height ?? 0
                let index = max(exSkill.skill.baseXpCost() - 1, 0)
                let baseHeight = tallestHeightRows[index] ?? 0
                let heightDelta = expandedHeight - baseHeight

                let yEx = expandedSkill?.gridY ?? 999999
                if diamondNum > yEx {
                    y += heightDelta
                }
            }
            let xpArea = CGRect(x: xLoc, y: prevY, width: horPadding + horPadding + collapsedWidth, height: y - prevY)
            let center = xpArea.center()
            
            let halfWidth = collapsedWidth / 2
            let halfHeight = collapsedWidth / 2
            
            let points = [
                CGPoint(x: center.x, y: center.y - (halfHeight)), // Top
                CGPoint(x: center.x + halfWidth, y: center.y), // Right
                CGPoint(x: center.x, y: center.y + halfHeight), // Bottom
                CGPoint(x: center.x - halfWidth, y: center.y) // Left
            ]
            
            var path = Path()
            path.move(to: points[0])
            for p in points[1...] {
                path.addLine(to: p)
            }
            path.addLine(to: points[0])
            path.closeSubpath()
            
            context.stroke(path, with: .color(.white), lineWidth: 5)
            
            let text = Text("\(diamondNum)").font(.system(size: 50, weight: .bold)).foregroundColor(.white)
            context.draw(text, at: center, anchor: .center)
            prevY = y
        }
        
    }
    
    private func drawLines(_ context: SwiftUICore.GraphicsContext, finalX: CGFloat) {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: -vertPadding))
        path.addLine(to: CGPoint(x: finalX, y: -vertPadding))
        context.stroke(path, with: .color(.white), style: StrokeStyle(lineWidth: 5))
        
        context.stroke(getHorizontalDashedLinePath(1, finalX: finalX), with: .color(.white), style: StrokeStyle(lineWidth: 5, dash: [16, 5]))
        context.stroke(getHorizontalDashedLinePath(2, finalX: finalX), with: .color(.white), style: StrokeStyle(lineWidth: 5, dash: [16, 5]))
        context.stroke(getHorizontalDashedLinePath(3, finalX: finalX), with: .color(.white), style: StrokeStyle(lineWidth: 5, dash: [16, 5]))
        context.stroke(getHorizontalDashedLinePath(4, finalX: finalX), with: .color(.white), style: StrokeStyle(lineWidth: 5, dash: [16, 5]))
    }

    
    private func getHorizontalDashedLinePath(_ lineNum: Int, finalX: CGFloat) -> Path {
        var y = ((tallestHeightRows[lineNum - 1] ?? 0) * 2 * lineNum.cgFloat)
        y += (vertPadding * 3 * lineNum.cgFloat)
        if let exSkill = expandedSkill {
            let expandedHeight = skillSizes[exSkill.skill.id]?.height ?? 0
            let index = max(exSkill.skill.baseXpCost() - 1, 0)
            let baseHeight = tallestHeightRows[index] ?? 0
            let heightDelta = expandedHeight - baseHeight

            let yEx = expandedSkill?.gridY ?? 999999
            if lineNum > yEx {
                y += heightDelta
            }
        }
        var path = Path()
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: finalX, y: y))
        return path
    }
    
    private func forceRefresh() {
        // TODO
//        DispatchQueue.main.async {
//            self.trueGrid = trueGrid
//        }
    }
    
    private func getTappedOnSkill(x: CGFloat, y: CGFloat) -> Int? {
        return skillGrid.trueGrid.firstIndex(where: { getHitRect($0).contains(x: x, y: y) })
    }
    
    private func tappedOnPurchase(_ gridSkill: GridSkill, x: CGFloat, y: CGFloat) -> Bool {
        guard skillGrid.allowPurchase else { return false }
        let height = skillSizes[gridSkill.skill.id]?.height ?? 0
        let buttonHeight: CGFloat = 90
        let buttonWidth: CGFloat = expandedWidth - 64
        let buttonXOffset: CGFloat = 32
        let buttonYOffset: CGFloat = 32
        let skillX = getGridX(gridSkill, gridSkill.gridX)
        let skillY = getGridY(gridSkill, gridSkill.gridY)
        
        let rect = CGRect(x: skillX + buttonXOffset, y: skillY - buttonYOffset - buttonHeight + height, width: buttonWidth, height: buttonHeight)
        return rect.contains(x: x, y: y)
    }
    
    private func getHitRect(_ gridSkill: GridSkill) -> CGRect {
        let xEx = self.expandedSkill?.gridX ?? 99999
        let yEy = self.expandedSkill?.gridY ?? 99999
        let width = gridSkill.expanded ? expandedWidth : collapsedWidth
        let index = max(gridSkill.skill.baseXpCost() - 1, 0)
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
        x += horPadding * gridSkill.skill.category.id.cgFloat
        if gridSkill.skill.category.id > 1 {
            x += horPadding + horPadding + collapsedWidth
        }
        return x
    }
    
    private func getGridY(_ gridSkill: GridSkill, _ yEx: Int) -> CGFloat {
        let gridY = gridSkill.gridY.cgFloat
        let index = max(gridSkill.skill.baseXpCost() - 1, 0)
        var y = gridY * ((tallestHeightRows[index] ?? 0) * 2)
        y += (gridY * vertPadding * 3)
        y += vertPadding
        if gridSkill.lowered {
            y += (tallestHeightRows[index] ?? 0)
            y += vertPadding
        }
        if let exSkill = expandedSkill {
            let expandedHeight = skillSizes[exSkill.skill.id]?.height ?? 0
            let index = max(exSkill.skill.baseXpCost() - 1, 0)
            let baseHeight = tallestHeightRows[index] ?? 0
            let heightDelta = expandedHeight - baseHeight

            if gridSkill.gridY > yEx || (gridSkill.gridY == yEx && gridSkill.lowered && exSkill.lowered == false) {
                y += heightDelta
            }
        }
        return y
    }

    private func calcTallestHeightRows() {
        for skill in skillGrid.skills {
            let size = skillSizes[skill.id] ?? .zero
            let index = max(skill.baseXpCost() - 1, 0)
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

                currentScale = (currentScale * delta).clamped(to: 0.01...100)

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
        // TODO redo this
//        if !isPurchasing, let expandedSkill = expandedSkill, expandedSkill.expanded, tappedOnPurchase(expandedSkill, x: x, y: y) {
//            self.isPurchasing = true
//            self.loadingText = "Purchasing..."
//            Task {
//                let dots = ["", ".", "..", "..."]
//                var i = 0
//                while isPurchasing {
//                    await MainActor.run {
//                        self.loadingText = "Purchasing" + dots[i % dots.count]
//                    }
//                    try? await Task.sleep(nanoseconds: 250000000) // 0.25 seconds
//                    i += 1
//                }
//            }
//            if let player = player, let char = character, let skl = availableSkills.first(where: { $0.id == expandedSkill.skill.id }) {
//                // TODO redo this
//                var xpSpent = 0
//                var fsSpent = 0
//                var ppSpent = 0
//
//                var msgStr = "It will cost you "
//
//                if skl.canUseFreeSkill, Int(player.freeTier1Skills) ?? 0 > 0 {
//                    msgStr += "1 Free Tier-1 Skill point (you have \(player.freeTier1Skills) FT1S)"
//                    fsSpent = 1
//                } else {
//                    msgStr += "\(skl.modXpCost)xp (you have \(player.experience)xp)"
//                    xpSpent = Int(skl.modXpCost) ?? 0
//                }
//
//                if skl.usesPrestige {
//                    msgStr += " and \(skl.prestigeCost) Prestige point (you have \(player.prestigePoints)pp)"
//                    ppSpent = 1
//                }
//                
//                runOnMainThread {
//                    AlertManager.shared.showOkCancelAlert("Are you sure you want to purchase \(skl.name)", message: msgStr) {
//                        let charSkill = CharacterSkillCreateModel(characterId: char.id, skillId: skl.id, xpSpent: xpSpent, fsSpent: fsSpent, ppSpent: ppSpent)
//                        CharacterSkillService.takeSkill(charSkill, playerId: player.id) { _ in
//                            OldDM.load([.player, .character], forceDownloadIfApplicable: true) {
//                                runOnMainThread {
//                                    AlertManager.shared.showOkAlert("\(skl.name) Purchased!") {}
//                                    self.player = OldDM.player
//                                    self.character = OldDM.character
//                                    self.availableSkills = getAvailableSkills() ?? []
//                                    self.isPurchasing = false
//                                    self.forceRefresh()
//                                }
//                            }
//                        } failureCase: { error in
//                            runOnMainThread {
//                                self.isPurchasing = false
//                            }
//                        }
//
//                    } onCancelAction: {
//                        runOnMainThread {
//                            self.isPurchasing = false
//                        }
//                    }
//                }
//                
//            }
//        } else if let tappedSkillIndex = getTappedOnSkill(x: x, y: y) {
//            let oldState = trueGrid[tappedSkillIndex].expanded
//            for index in trueGrid.indices {
//                trueGrid[index].expanded = false
//            }
//            trueGrid[tappedSkillIndex].expanded = !oldState
//            self.expandedSkill = !oldState ? trueGrid[tappedSkillIndex] : nil
//            
//            forceRefresh()
//        } else {
//            for index in trueGrid.indices {
//                trueGrid[index].expanded = false
//            }
//            self.expandedSkill = nil
//            forceRefresh()
//        }
    }

}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

