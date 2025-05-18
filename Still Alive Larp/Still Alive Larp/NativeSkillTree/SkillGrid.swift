import SwiftUI

class SkillGrid {
    private let personal: Bool
    private let allowPurchase: Bool

    let skills: [FullSkillModel]
    private var purchaseableSkills: [CharacterModifiedSkillModel] = []
    private let skillCategories: [SkillCategoryModel]
    private var gridCategories: [SkillGridCategory] = []
    var trueGrid: [GridSkill] = []

    private var purchaseButton: TappablePurchaseButton?

    // Grid layout constants
    private let skillWidth: CGFloat = 300
    private let skillWidthExpanded: CGFloat = 600
    private let skillHeight: CGFloat = 300
    private let spacingWidth: CGFloat = 75
    private let spacingHeight: CGFloat = 150
    private let lineHeight: CGFloat = 150 / 2
    private let fullTitleSize: CGFloat = 100
    private let textSize: CGFloat = 35
    private let titleSize: CGFloat = 60
    private let titleSpacing: CGFloat = 20
    private let numberCircleRadius: CGFloat = 50
    private let textPadding: CGFloat = 4

    private let skillReqSpacing: CGFloat = 25

    private var firstLineYOffset: CGFloat = 0
    private var secondLineYOffset: CGFloat = 0
    private var thirdLineYOffset: CGFloat = 0
    private var lineStartXOffset: CGFloat = 0
    private var lineEndXOffset: CGFloat = 0

    private let xpCostWidth: CGFloat = 300 + 75 + 75 // same as skillWidth + spacingWidth*2
    private let diamondWidth: CGFloat = 300
    private let diamondHeight: CGFloat = 300

    private let buttonOutlineHeight: CGFloat = 8

    // Stroke/fill colors (used with Canvas)
    private let blackPaint = Color.black
    private let whitePaint = Color.white
    private let outlineStroke = StrokeStyle(lineWidth: 5)
    private let fillStroke = StrokeStyle(lineWidth: 5)

    // Gradient colors
    private let lightGray = Color(hex: "#DDDDDD")
    private let darkGray = Color(hex: "#999999")
    private let lightGrayDull = Color(hex: "#797979")
    private let darkGrayDull = Color(hex: "#353535")

    private let lightRed = Color(hex: "#F7C9C6")
    private let darkRed = Color(hex: "#EA6E69")
    private let lightRedDull = Color(hex: "#936562")
    private let darkRedDull = Color(hex: "#860A05")

    private let lightBlue = Color(hex: "#D8E7FB")
    private let darkBlue = Color(hex: "#7FA7E0")
    private let lightBlueDull = Color(hex: "#748397")
    private let darkBlueDull = Color(hex: "#1B437C")

    private let lightGreen = Color(hex: "#CAE1C5")
    private let darkGreen = Color(hex: "#98D078")
    private let lightGreenDull = Color(hex: "#667D61")
    private let darkGreenDull = Color(hex: "#346C14")

    @State private var dotCount = 0
    @State private var baseText = "Purchasing"
    @State private var makingPurchase = false
    private var dotTimer: Timer?

    private func startDotTimer() {
        dotTimer?.invalidate()
        dotTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if self.makingPurchase {
                self.dotCount = (self.dotCount + 1) % 4
                self.invalidate()
            }
        }
    }

    private func stopDotTimer() {
        dotTimer?.invalidate()
        dotTimer = nil
    }

    var fullGrid: [[FullSkillModel?]] = []
    var gridConnections: [GridConnection] = []
    var invalidate: () -> Void = {}

    init(skills: [FullSkillModel], skillCategories: [SkillCategoryModel], personal: Bool, allowPurchase: Bool) {
        self.skills = skills
        self.skillCategories = skillCategories
        self.personal = personal
        self.allowPurchase = allowPurchase

        self.calculateWidthAndHeightOfGridCategories()
        self.orderCategories()
        self.fullGrid = self.calculateFullGrid()
        self.gridConnections = self.buildConnections()
        self.trueGrid = self.calculateTrueGrid()

        if personal && allowPurchase {
            self.purchaseableSkills = getAvailableSkills(
                skills: skills,
                player: DataManager.shared.selectedPlayer,
                character: DataManager.shared.charForSelectedPlayer,
                xpReductions: DataManager.shared.xpReductions
            )
        }
    }
    
    private func getAvailableSkills(
        skills: [FullSkillModel]?,
        player: PlayerModel?,
        character: FullCharacterModel?,
        xpReductions: [SpecialClassXpReductionModel]?
    ) -> [CharacterModifiedSkillModel] {
        let allSkills = skills ?? []
        let charSkills = character?.skills ?? []

        // Remove already-owned skills
        var newSkillList = allSkills.filter { skill in
            !charSkills.contains(where: { $0.id == skill.id })
        }

        // Filter for prerequisite fulfillment
        newSkillList = newSkillList.filter { skill in
            skill.prereqs.allSatisfy { prereq in
                charSkills.contains(where: { $0.id == prereq.id })
            }
        }

        // Check prestige points
        newSkillList = newSkillList.filter { skill in
            skill.prestigeCost <= (player?.prestigePoints ?? "")
        }

        // Filter choose-one skills
        let cskills = character?.getChooseOneSkills() ?? []
        if cskills.isEmpty {
            newSkillList = newSkillList.filter {
                !Constants.SpecificSkillIds.allLevel2SpecialistSkills.contains($0.id)
            }
        } else if cskills.count == 2 {
            newSkillList = newSkillList.filter {
                !Constants.SpecificSkillIds.allSpecalistSkills.contains($0.id)
            }
        } else if let cskill = cskills.first {
            let idsToRemove: [Int]
            switch cskill.id {
            case Constants.SpecificSkillIds.expertCombat:
                idsToRemove = Constants.SpecificSkillIds.allSpecalistsNotUnderExpertCombat
            case Constants.SpecificSkillIds.expertProfession:
                idsToRemove = Constants.SpecificSkillIds.allSpecalistsNotUnderExpertProfession
            case Constants.SpecificSkillIds.expertTalent:
                idsToRemove = Constants.SpecificSkillIds.allSpecalistsNotUnderExpertTalent
            default:
                idsToRemove = []
            }
            newSkillList = newSkillList.filter { !idsToRemove.contains($0.id) }
        }

        // XP / infection mods
        let combatXpMod = character?.costOfCombatSkills() ?? 0
        let professionXpMod = character?.costOfProfessionSkills() ?? 0
        let talentXpMod = character?.costOfTalentSkills() ?? 0
        let inf50Mod = character?.costOf50InfectSkills() ?? 50
        let inf75Mod = character?.costOf75InfectSkills() ?? 75

        // Convert to modified skill list
        let modSkillList = newSkillList.map { skill in
            CharacterModifiedSkillModel(
                skill,
                modXpCost: skill.getModCost(
                    combatMod: combatXpMod,
                    professionMod: professionXpMod,
                    talentMod: talentXpMod,
                    xpReductions: xpReductions ?? []
                ),
                modInfCost: skill.getInfModCost(inf50Mod: inf50Mod, inf75Mod: inf75Mod)
            )
        }

        // Final XP/INF filter
        return modSkillList.filter { modSkill in
            let xp = player?.experience.intValueDefaultZero ?? 0
            let inf = character?.infection.intValueDefaultZero ?? 0
            let modXp = Int(modSkill.modXpCost) ?? Int.max
            let modInf = Int(modSkill.modInfCost) ?? Int.max

            if modInf > inf { return false }
            if modXp > xp {
                return modSkill.canUseFreeSkill && (player?.freeTier1Skills.intValueDefaultZero ?? 0) > 0
            }
            return true
        }
    }
    
    func getSkillShading(x: CGFloat, y: CGFloat, skill: FullSkillModel) -> GraphicsContext.Shading {
        let centerX = x + skillWidth / 2
        let startPoint = CGPoint(x: centerX, y: y)
        let endPoint = CGPoint(x: centerX, y: y + skillHeight)

        let isOwned = personal && (DataManager.shared.charForSelectedPlayer?.skills.contains { $0.id == skill.id } ?? false)
        let isPurchasable = couldPurchaseSkill(skill: skill)

        func shading(from top: Color, to bottom: Color) -> GraphicsContext.Shading {
            return .linearGradient(
                Gradient(colors: [top, bottom]),
                startPoint: startPoint,
                endPoint: endPoint
            )
        }

        switch skill.skillTypeId {
        case Constants.SkillTypes.combat:
            return shading(
                from: selectColor(owned: isOwned, purchasable: isPurchasable, normal: lightRed, dull: lightRedDull),
                to:   selectColor(owned: isOwned, purchasable: isPurchasable, normal: darkRed, dull: darkRedDull)
            )
        case Constants.SkillTypes.profession:
            return shading(
                from: selectColor(owned: isOwned, purchasable: isPurchasable, normal: lightGreen, dull: lightGreenDull),
                to:   selectColor(owned: isOwned, purchasable: isPurchasable, normal: darkGreen, dull: darkGreenDull)
            )
        case Constants.SkillTypes.talent:
            return shading(
                from: selectColor(owned: isOwned, purchasable: isPurchasable, normal: lightBlue, dull: lightBlueDull),
                to:   selectColor(owned: isOwned, purchasable: isPurchasable, normal: darkBlue, dull: darkBlueDull)
            )
        default:
            return shading(from: lightGrayDull, to: darkGrayDull)
        }
    }
    
    func selectColor(owned: Bool, purchasable: Bool, normal: Color, dull: Color) -> Color {
        if !personal || owned {
            return normal
        } else if purchasable {
            return dull
        } else {
            return lightGrayDull
        }
    }

    private func chooseColors(
        owned: Bool,
        purchasable: Bool,
        normal: (Color, Color),
        dull: (Color, Color)
    ) -> [Color] {
        if owned || !personal {
            return [normal.0, normal.1]
        } else if purchasable {
            return [dull.0, dull.1]
        } else {
            return [lightGrayDull, darkGrayDull]
        }
    }
    
    func getSkillConnectionColor(typeId: Int) -> Color {
        switch typeId {
        case Constants.SkillTypes.combat:
            return darkRed
        case Constants.SkillTypes.profession:
            return darkGreen
        case Constants.SkillTypes.talent:
            return darkBlue
        default:
            return .black
        }
    }

    private func couldPurchaseSkill(skill: FullSkillModel) -> Bool {
        if personal && allowPurchase {
            return purchaseableSkills.contains { $0.id == skill.id }
        }
        return false
    }

    private func orderCategories() {
        gridCategories.sort { $0.skillCategoryId < $1.skillCategoryId }
    }

    private func calculateFullGrid() -> [[FullSkillModel?]] {
        var grid: [[FullSkillModel?]] = Array(repeating: [], count: 4)

        for category in gridCategories {
            for branch in category.branches {
                for (xpCost, row) in branch.grid.enumerated() {
                    for skill in row {
                        grid[xpCost].append(skill)
                    }
                }
            }
        }

        return grid
    }

    private func getSkill(_ skillId: Int) -> FullSkillModel {
        return skills.first { $0.id == skillId }!
    }

    private func getGridLocation(_ skillId: Int) -> GridLocation? {
        for (y, row) in fullGrid.enumerated() {
            for (x, skill) in row.enumerated() {
                if skill?.id == skillId {
                    let hasMatchingPrereq = skill?.prereqs.contains {
                        $0.xpCost.intValueDefaultZero == skill?.xpCost.intValueDefaultZero
                    } ?? false
                    return GridLocation(x: x, y: y, isLowered: hasMatchingPrereq)
                }
            }
        }
        return nil
    }
    
    private func buildConnections() -> [GridConnection] {
        var connections: [GridConnection] = []

        for (y, row) in fullGrid.enumerated() {
            for (x, skill) in row.enumerated() {
                guard let skill = skill else { continue }
                let postReqCount = Double(skill.postreqs.count)
                let increment = 1.0 / (postReqCount + 1.0)
                var index = 0

                for postId in skill.postreqs {
                    if let toLocation = getGridLocation(postId) {
                        let fromVertical = skill.prereqs.contains { $0.xpCost.intValueDefaultZero == skill.xpCost.intValueDefaultZero }
                        let fromLocation = GridLocation(x: x, y: y, isLowered: fromVertical)
                        let color = getSkillConnectionColor(typeId: skill.skillTypeId)
                        let toSkill = getSkill(postId)
                        let prereqCount = toSkill.prereqs.count
                        let connection = GridConnection(
                            from: fromLocation,
                            to: toLocation,
                            mult: increment,
                            color: color,
                            prereqs: prereqCount,
                            fromCategoryId: skill.skillCategoryId
                        )
                        connections.append(connection)
                        index += 1
                    }
                }
            }
        }

        // Sort connections
        connections.sort {
            if $0.from.x != $1.from.x { return $0.from.x < $1.from.x }
            if $0.from.y != $1.from.y { return $0.from.y < $1.from.y }
            if $0.directionPriority() != $1.directionPriority() { return $0.directionPriority() < $1.directionPriority() }
            return $0.distance() < $1.distance()
        }

        // Adjust multipliers
        var prevX = -1
        var prevY = -1
        var count = 0
        for i in 0..<connections.count {
            let gc = connections[i]
            if gc.from.x != prevX || gc.from.y != prevY {
                prevX = gc.from.x
                prevY = gc.from.y
                count = 0
            }
            count += 1
            connections[i].mult *= Double(count)
        }

        return connections
    }

    func handleTap(x: CGFloat, y: CGFloat) {
        guard !makingPurchase else { return }

        if let pb = purchaseButton?.copy(),
           pb.rect.contains(x: x, y: y),
           couldPurchaseSkill(skill: pb.skill.fullSkillModel) {
            purchaseSkill(pb: pb)

        } else if let index = trueGrid.firstIndex(where: { $0.rect.contains(x: x, y: y) }) {
            let wasExpanded = trueGrid[index].expanded
            for i in 0..<trueGrid.count {
                trueGrid[i].expanded = false
            }
            trueGrid[index].expanded = !wasExpanded
            trueGrid = calculateTrueGrid()
            recalculateDottedLines()
        }
    }

    func purchaseSkill(pb: TappablePurchaseButton) {
        makingPurchase = true
        // start animating dotted lines, e.g., with Timer

        let skl = pb.skill
        let player = DataManager.shared.selectedPlayer!
        let char = DataManager.shared.charForSelectedPlayer!
        var xpSpent = 0
        var fsSpent = 0
        var ppSpent = 0

        var msgStr = "It will cost you "

        if skl.canUseFreeSkill, Int(player.freeTier1Skills) ?? 0 > 0 {
            msgStr += "1 Free Tier-1 Skill point (you have \(player.freeTier1Skills))"
            fsSpent = 1
        } else {
            msgStr += "\(skl.modXpCost)xp (you have \(player.experience)xp)"
            xpSpent = Int(skl.modXpCost) ?? 0
        }

        if skl.usesPrestige {
            msgStr += " and 1 Prestige point (you have \(player.prestigePoints))"
            ppSpent = 1
        }
        
        // TODO alert and service call

        // Then trigger an async UI alert and call your skill purchase service
        // (you’ll use confirmation alerts via `.alert(...)` modifiers in the view layer)

        // After purchase:
        // - update DataManager.shared.selectedPlayer
        // - append skill to char.skills
        // - update `purchaseableSkills`, `trueGrid`, and redraw
        // - stop animation, set `makingPurchase = false`
    }
    
    func getExpanded() -> GridSkill? {
        guard let index = trueGrid.firstIndex(where: { $0.expanded }) else { return nil }

        let rect = trueGrid[index].rect
        let expandedHeight = CGFloat(calculateExpandedHeight(gs: trueGrid[index]))
        trueGrid[index].rect = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: skillWidthExpanded,
            height: expandedHeight
        )
        return trueGrid[index]
    }

    func calculateExpandedHeight(gs: GridSkill) -> CGFloat {
        let skill = gs.skill
        let sectionSpacing = CGFloat(textPadding * 4)
        let lineHeight = CGFloat(4)
        var totalHeight = CGFloat(0)

        let widthMain = Int(skillWidthExpanded * 0.75) - Int(textPadding * 2)
        let widthSide = Int(skillWidthExpanded * 0.25) - Int(textPadding * 2)
        let fullWidth = Int(skillWidthExpanded) - Int(textPadding * 2)

        // Estimate heights using number of lines (simplified)
        let titleHeight = estimateHeight(text: skill.name, width: widthMain) + textPadding * 2
        let typeHeight = estimateHeight(text: skill.getTypeText(), width: widthSide) + textPadding * 2
        totalHeight += max(titleHeight, typeHeight) + sectionSpacing

        totalHeight += lineHeight + sectionSpacing

        totalHeight += estimateHeight(text: skill.getFullCostText(purchaseableSkills: purchaseableSkills), width: fullWidth) + textPadding * 2 + sectionSpacing
        totalHeight += lineHeight + sectionSpacing

        if !skill.prereqs.isEmpty {
            totalHeight += estimateHeight(text: "Prerequisites", width: fullWidth) + textPadding * 2
            for prereq in skill.prereqs {
                totalHeight += estimateHeight(text: prereq.name, width: fullWidth) + textPadding * 2
            }
            totalHeight += sectionSpacing
            totalHeight += lineHeight + sectionSpacing
        }

        totalHeight += estimateHeight(text: skill.description, width: fullWidth) + textPadding * 2

        if personal, allowPurchase, purchaseableSkills.contains(where: { $0.id == skill.id }) {
            totalHeight = totalHeight + 100 + (textPadding * 8) + (buttonOutlineHeight * 2)
        }

        return totalHeight
    }

    private func estimateHeight(text: String, width: Int) -> CGFloat {
        // Very rough: assume ~20 px/line, 30 chars/line
        let lines = (text.count / max((width / 10), 1)) + 1
        return CGFloat(lines * 20)
    }

    private func calculateWidthAndHeightOfGridCategories() {
        var skillsCategorized: [Int: [FullSkillModel]] = [:]

        for skill in skills {
            let key = Int(skill.skillCategoryId)
            skillsCategorized[key, default: []].append(skill)
        }

        for (categoryId, skills) in skillsCategorized {
            if let cat = skillCategories.first(where: { $0.id == categoryId }) {
                let gridCat = SkillGridCategory(
                    skills: skills,
                    skillCategoryId: categoryId,
                    skillCategoryName: cat.name,
                    allSkills: self.skills
                )
                gridCategories.append(gridCat)
            }
        }
    }

    private func calculateTrueGrid() -> [GridSkill] {
        var exExists = false
        var exTier = 0
        var exHeightDifference: CGFloat = 0
        var exIsLower = false
        var exXLoc = 0
        var exSkillId = -1

        if let exSkill = getExpanded() {
            exExists = true
            exTier = max(exSkill.skill.xpCost.intValueDefaultZero - 1, 0)
            exHeightDifference = exSkill.rect.height - skillHeight
            exIsLower = exSkill.skill.prereqs.contains {
                $0.xpCost.intValueDefaultZero == exSkill.skill.xpCost.intValueDefaultZero && $0.skillCategoryId == exSkill.skill.skillCategoryId
            }
            exXLoc = exSkill.gridX
            exSkillId = exSkill.skill.id
        }

        var gridSkills: [GridSkill] = []

        for (xpCost, row) in fullGrid.enumerated() {
            for (skillIndex, skill) in row.enumerated() {
                guard let skill = skill else { continue }

                let hasVerticalPrereq = skill.prereqs.contains {
                    $0.xpCost.intValueDefaultZero == skill.xpCost.intValueDefaultZero && $0.skillCategoryId == skill.skillCategoryId
                }

                var y: CGFloat
                if !hasVerticalPrereq {
                    y = CGFloat(xpCost) * (skillHeight * 2 + spacingHeight * 4) + spacingHeight + titleSize + titleSpacing
                } else {
                    y = CGFloat(xpCost) * (skillHeight * 2 + spacingHeight * 4) + skillHeight + spacingHeight * 2 + titleSize + titleSpacing
                }

                var xOffset: CGFloat = 0
                if skill.skillCategoryId > Constants.SpecificSkillCategories.beginner {
                    xOffset = xpCostWidth
                }

                var x = spacingWidth + CGFloat(skillIndex) * (skillWidth + spacingWidth * 2) + xOffset

                if exExists {
                    if skillIndex > exXLoc {
                        x += skillWidthExpanded - skillWidth
                    }

                    if xpCost > exTier {
                        y += exHeightDifference
                    } else if xpCost == exTier {
                        if !exIsLower && hasVerticalPrereq {
                            y += exHeightDifference
                        }
                    }
                }

                let isExpanded = (skill.id == exSkillId)
                let rect = CGRect(
                    x: x,
                    y: y,
                    width: isExpanded ? skillWidthExpanded : skillWidth,
                    height: isExpanded ? skillHeight + exHeightDifference : skillHeight
                )

                gridSkills.append(GridSkill(rect: rect, skill: skill, gridX: skillIndex, gridY: xpCost, expanded: isExpanded))
            }
        }

        return gridSkills
    }

    private func recalculateDottedLines() {
        firstLineYOffset = 0
        secondLineYOffset = 0
        thirdLineYOffset = 0
        lineStartXOffset = 0
        lineEndXOffset = 0

        guard let expanded = getExpanded() else { return }

        let offset = expanded.rect.height - skillHeight
        lineEndXOffset = expanded.rect.width - skillWidth

        switch expanded.gridY {
        case 0:
            firstLineYOffset = offset
            secondLineYOffset = offset
            thirdLineYOffset = offset
        case 1:
            secondLineYOffset = offset
            thirdLineYOffset = offset
        case 2:
            thirdLineYOffset = offset
        default:
            break
        }

        if expanded.skill.skillCategoryId == Constants.SpecificSkillCategories.beginner {
            lineStartXOffset = expanded.rect.width - skillWidth
        }
    }
    
    func draw(in context: GraphicsContext, size: CGSize) {
        purchaseButton = nil
        let exSkill = getExpanded()
        var skillRequirements: [SkillRequirement] = []

        var widthSoFar: CGFloat = 0
        var startDottedLinesX: CGFloat = 0
        var finalDottedLineX: CGFloat = 0

        // --- CATEGORY BOXES AND TITLES ---
        for (index, category) in gridCategories.enumerated() {
            var extraXOffset: CGFloat = 0
            var extraWidth: CGFloat = 0
            var extraHeight: CGFloat = 0

            if let ex = exSkill {
                if ex.skill.skillCategoryId - 1 < category.skillCategoryId {
                    extraXOffset = skillWidthExpanded - skillWidth
                }
                if ex.skill.skillCategoryId - 1 == category.skillCategoryId {
                    extraWidth = skillWidthExpanded - skillWidth
                    extraHeight = ex.rect.height - skillHeight
                }
            }

            let categoryRect = CGRect(
                x: widthSoFar + extraXOffset,
                y: 0,
                width: CGFloat(category.width) * skillWidth + extraWidth + CGFloat(category.width) * 2 * spacingWidth,
                height: 8 * skillHeight + 16 * spacingHeight + extraHeight
            )

            context.stroke(Path(categoryRect), with: .color(.white), lineWidth: 2)

            let titleText = Text(category.skillCategoryName)
                .font(.system(size: titleSize))
                .foregroundColor(.white)

            context.draw(titleText, at: CGPoint(x: categoryRect.midX, y: titleSize + titleSpacing))

            widthSoFar += CGFloat(category.width) * skillWidth + CGFloat(category.width) * spacingWidth * 2

            if category.skillCategoryId == Constants.SpecificSkillCategories.beginner {
                // XP COLUMN
                let xpRect = CGRect(
                    x: widthSoFar + extraXOffset + extraWidth,
                    y: 0,
                    width: xpCostWidth,
                    height: 8 * skillHeight + spacingHeight * 16 + extraHeight
                )
                context.stroke(Path(xpRect), with: .color(.white), lineWidth: 2)

                let xpTitle = Text("Tier - XP Cost")
                    .font(.system(size: titleSize))
                    .foregroundColor(.white)

                context.draw(xpTitle, at: CGPoint(x: xpRect.midX, y: titleSize + titleSpacing))

                let startX = widthSoFar + extraXOffset + extraWidth + spacingWidth

                var startY: [CGFloat] = [
                    skillHeight + spacingHeight,
                    0, 0, 0
                ]
                startY[1] = startY[0] + 2 * skillHeight + 4 * spacingHeight
                startY[2] = startY[1] + 2 * skillHeight + 4 * spacingHeight
                startY[3] = startY[2] + 2 * skillHeight + 4 * spacingHeight

                if let ex = exSkill, ex.expanded {
                    let tier = min(4, ex.skill.xpCost.intValueDefaultZero)
                    for i in 0..<tier {
                        startY[i] += ex.rect.height - skillHeight
                    }
                }

                for i in 0..<4 {
                    let center = CGPoint(x: startX + diamondWidth / 2, y: startY[i] + diamondHeight / 2)

                    let diamond = Path { path in
                        path.move(to: CGPoint(x: center.x, y: center.y - diamondHeight / 2))
                        path.addLine(to: CGPoint(x: center.x + diamondWidth / 2, y: center.y))
                        path.addLine(to: CGPoint(x: center.x, y: center.y + diamondHeight / 2))
                        path.addLine(to: CGPoint(x: center.x - diamondWidth / 2, y: center.y))
                        path.closeSubpath()
                    }

                    context.stroke(diamond, with: .color(.white), lineWidth: 2)

                    let label = Text("\(i + 1)")
                        .font(.system(size: titleSize))
                        .foregroundColor(.white)

                    context.draw(label, at: center)
                }

                startDottedLinesX = widthSoFar
                widthSoFar += xpCostWidth
            }

            if index == gridCategories.count - 1 {
                finalDottedLineX = widthSoFar
            }
        }

        // --- DRAW TIER DOTTED LINES ---
        let dottedLineColor = Color.white

        let firstY = 2 * skillHeight + 4 * spacingHeight + firstLineYOffset
        let secondY = 4 * skillHeight + 8 * spacingHeight + secondLineYOffset
        let thirdY = 6 * skillHeight + 12 * spacingHeight + thirdLineYOffset

        let startX = startDottedLinesX + lineStartXOffset
        let endX = finalDottedLineX + lineEndXOffset

        let firstLine = Path { path in
            path.move(to: CGPoint(x: startX, y: firstY))
            path.addLine(to: CGPoint(x: endX, y: firstY))
        }
        let secondLine = Path { path in
            path.move(to: CGPoint(x: startX, y: secondY))
            path.addLine(to: CGPoint(x: endX, y: secondY))
        }
        let thirdLine = Path { path in
            path.move(to: CGPoint(x: startX, y: thirdY))
            path.addLine(to: CGPoint(x: endX, y: thirdY))
        }
        let strokeStyle = StrokeStyle(lineWidth: 5, dash: [30, 30])
        context.stroke(firstLine, with: .color(dottedLineColor), style: strokeStyle)
        context.stroke(secondLine, with: .color(dottedLineColor), style: strokeStyle)
        context.stroke(thirdLine, with: .color(dottedLineColor), style: strokeStyle)

        for skillItem in trueGrid {
            let rect = skillItem.rect
            let x = rect.minX
            let y = rect.minY
            let skill = skillItem.skill
            
            if skill.skillCategoryId == Constants.SpecificSkillCategories.infected {
                let text = Text("At Least \(skill.minInfection)% Infection Rating Required")
                    .font(.system(size: 30))
                    .foregroundColor(.white)

                let resolved = context.resolve(text)
                let measured = resolved.measure(in: CGSize(width: skillWidth, height: .infinity))
                let rect = CGRect(
                    x: x - CGFloat(textPadding),
                    y: y - CGFloat(skillReqSpacing) - measured.height - CGFloat(textPadding),
                    width: skillWidth + CGFloat(textPadding),
                    height: measured.height + CGFloat(textPadding)
                )
                skillRequirements.append(SkillRequirement(rect: rect, text: text))
            }

            if skill.skillCategoryId == Constants.SpecificSkillCategories.prestige {
                let text = Text("Requires 1 Prestige Point")
                    .font(.system(size: 30))
                    .foregroundColor(.white)

                let resolved = context.resolve(text)
                let measured = resolved.measure(in: CGSize(width: skillWidth, height: .infinity))
                let rect = CGRect(
                    x: x - CGFloat(textPadding),
                    y: y - CGFloat(skillReqSpacing) - measured.height - CGFloat(textPadding),
                    width: skillWidth + CGFloat(textPadding),
                    height: measured.height + CGFloat(textPadding)
                )
                skillRequirements.append(SkillRequirement(rect: rect, text: text))
            }

            if skill.skillCategoryId == Constants.SpecificSkillCategories.spec {
                let text = Text("You may only select 1 Tier-\(skill.xpCost) Specialization Skill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)

                let resolved = context.resolve(text)
                let measured = resolved.measure(in: CGSize(width: skillWidth, height: .infinity))
                let rect = CGRect(
                    x: x - CGFloat(textPadding),
                    y: y - CGFloat(skillReqSpacing) - measured.height - CGFloat(textPadding),
                    width: skillWidth + CGFloat(textPadding),
                    height: measured.height + CGFloat(textPadding)
                )
                skillRequirements.append(SkillRequirement(rect: rect, text: text))
            }


            // Skill box background
            let shading = getSkillShading(x: x, y: y, skill: skillItem.skill)
            context.fill(Path(rect), with: shading)

            // If not expanded, draw skill name in center
            if !skillItem.expanded {
                let title = skillItem.skill.name
                let text = Text(title)
                    .font(.system(size: textSize))
                    .foregroundColor(.white)

                let textSize = context.resolve(text).measure(in: CGSize(width: skillWidth - 2 * spacingWidth, height: .infinity))

                let center = CGPoint(
                    x: rect.midX,
                    y: rect.midY - textSize.height / 2
                )
                context.draw(text, at: center, anchor: .top)
            }

            if skillItem.expanded {
                let skill = skillItem.skill
                var heightSoFar: CGFloat = 0
                let sectionSpacing = CGFloat(textPadding * 4)
                let lineHeight: CGFloat = 4

                let boxX = skillItem.rect.minX
                let boxY = skillItem.rect.minY
                let boxWidth = skillWidthExpanded

                // --- Title ---
                let titleText = Text(skill.name)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)

                let titleSize = context.resolve(titleText).measure(in: CGSize(width: boxWidth * 0.75, height: .infinity))
                context.draw(titleText, at: CGPoint(x: boxX + textPadding, y: boxY + textPadding), anchor: .topLeading)

                // --- Skill Type ---
                let typeText = Text(skill.getTypeText())
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                let typeSize = context.resolve(typeText).measure(in: CGSize(width: boxWidth * 0.25, height: .infinity))
                context.draw(typeText, at: CGPoint(x: boxX + boxWidth - textPadding * 2, y: boxY + textPadding), anchor: .topTrailing)

                heightSoFar += max(titleSize.height, typeSize.height) + sectionSpacing

                // --- Divider ---
                let divider1 = CGRect(x: boxX + sectionSpacing, y: boxY + heightSoFar, width: boxWidth - 2 * sectionSpacing, height: lineHeight)
                context.fill(Path(divider1), with: .color(Color.gray))
                heightSoFar += lineHeight + sectionSpacing

                // --- Cost ---
                let costText = Text(skill.getFullCostText(purchaseableSkills: purchaseableSkills))
                    .font(.system(size: 35))
                    .foregroundColor(.white)

                let costSize = context.resolve(costText).measure(in: CGSize(width: boxWidth - 2 * textPadding, height: .infinity))
                context.draw(costText, at: CGPoint(x: boxX + boxWidth / 2, y: boxY + heightSoFar + textPadding), anchor: .top)

                heightSoFar += costSize.height + textPadding * 2 + sectionSpacing

                // --- Divider ---
                let divider2 = CGRect(x: boxX + sectionSpacing, y: boxY + heightSoFar, width: boxWidth - 2 * sectionSpacing, height: lineHeight)
                context.fill(Path(divider2), with: .color(Color.gray))
                heightSoFar += lineHeight + sectionSpacing

                // --- Prerequisites (if any) ---
                if !skill.prereqs.isEmpty {
                    let prereqTitle = Text("Prerequisites")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundColor(.white)
                    let titleSize = context.resolve(prereqTitle).measure(in: CGSize(width: boxWidth - 2 * textPadding, height: .infinity))
                    context.draw(prereqTitle, at: CGPoint(x: boxX + boxWidth / 2, y: boxY + heightSoFar), anchor: .top)
                    heightSoFar += titleSize.height + textPadding * 2

                    for prereq in skill.prereqs {
                        let prereqText = Text(prereq.name)
                            .font(.system(size: 35))
                            .foregroundColor(.white)

                        let prereqSize = context.resolve(prereqText).measure(in: CGSize(width: boxWidth - 2 * textPadding, height: .infinity))
                        context.draw(prereqText, at: CGPoint(x: boxX + boxWidth / 2, y: boxY + heightSoFar), anchor: .top)
                        heightSoFar += prereqSize.height + textPadding * 2
                    }

                    // --- Divider ---
                    let divider3 = CGRect(x: boxX + sectionSpacing, y: boxY + heightSoFar, width: boxWidth - 2 * sectionSpacing, height: lineHeight)
                    context.fill(Path(divider3), with: .color(Color.gray))
                    heightSoFar += lineHeight + sectionSpacing
                }

                // --- Description ---
                let descText = Text(skill.description)
                    .font(.system(size: 35))
                    .foregroundColor(.white)

                let descSize = context.resolve(descText).measure(in: CGSize(width: boxWidth - 2 * textPadding, height: .infinity))
                context.draw(descText, at: CGPoint(x: boxX + boxWidth / 2, y: boxY + heightSoFar), anchor: .top)
                heightSoFar += descSize.height + textPadding * 2

                // --- Purchase Button ---
                if personal, allowPurchase, let pskill = purchaseableSkills.first(where: { $0.id == skill.id }) {
                    let buttonHeight: CGFloat = 100
                    let buttonY = boxY + heightSoFar + buttonOutlineHeight

                    let buttonRect = CGRect(
                        x: boxX + textPadding * 4,
                        y: buttonY,
                        width: skillWidthExpanded - textPadding * 8,
                        height: buttonHeight
                    )

                    context.fill(Path(buttonRect.insetBy(dx: -buttonOutlineHeight, dy: -buttonOutlineHeight)), with: .color(.black))
                    context.fill(Path(buttonRect), with: .color(Color(red: 145/255, green: 0, blue: 22/255)))

                    let buttonText = Text(makingPurchase ? "Purchasing" + String(repeating: ".", count: dotCount) : "Purchase Skill")
                        .font(.system(size: 70))
                        .foregroundColor(.white)

                    context.draw(buttonText, at: CGPoint(x: buttonRect.midX, y: buttonRect.minY + textPadding * 2), anchor: .top)

                    purchaseButton = TappablePurchaseButton(skill: pskill, rect: buttonRect)

                    heightSoFar += buttonHeight + textPadding * 8 + buttonOutlineHeight * 2
                }
            } else {
                let title = skillItem.skill.name
                let text = Text(title)
                    .font(.system(size: textSize))
                    .foregroundColor(.white)

                let textSize = context.resolve(text).measure(in: CGSize(width: skillWidth - 2 * textPadding, height: .infinity))
                let center = CGPoint(
                    x: rect.midX,
                    y: rect.midY - textSize.height / 2
                )
                context.draw(text, at: center, anchor: .top)
            }
            
            var circles: [CGCircle: Int] = [:]

            for connection in gridConnections {
                let fx = connection.from.x
                let fy = connection.from.y
                let tx = connection.to.x
                let ty = connection.to.y
                let mult = connection.mult

                let x = spacingWidth + (CGFloat(fx) * skillWidth) + (CGFloat(fx) * spacingWidth * 2) + (skillWidth * mult)
                let y: CGFloat = {
                    if !connection.from.isLowered {
                        return CGFloat(fy) * skillHeight * 2 + CGFloat(fy) * spacingHeight * 4 + spacingHeight + titleSize + titleSpacing + skillHeight
                    } else {
                        return CGFloat(fy) * skillHeight * 2 + CGFloat(fy) * spacingHeight * 4 + skillHeight + spacingHeight * 2 + titleSize + titleSpacing + skillHeight
                    }
                }()

                let targetX = spacingWidth + CGFloat(tx) * skillWidth + CGFloat(tx) * spacingWidth * 2 + skillWidth / 2
                let targetY: CGFloat = {
                    if !connection.to.isLowered {
                        return CGFloat(ty) * skillHeight * 2 + CGFloat(ty) * spacingHeight * 4 + spacingHeight + titleSize + titleSpacing
                    } else {
                        return CGFloat(ty) * skillHeight * 2 + CGFloat(ty) * spacingHeight * 4 + skillHeight + spacingHeight * 2 + titleSize + titleSpacing
                    }
                }()

                let lineMult = 1.0 - mult
                var dropVal: CGFloat = (connection.from.isLowered || fy == ty) ? 0 : skillHeight + spacingHeight

                var fxOffset: CGFloat = 0
                var txOffset: CGFloat = 0
                var fyOffset: CGFloat = 0
                var tyOffset: CGFloat = 0
                var initialYOffset: CGFloat = 0
                var xTravelOffset: CGFloat = 0
                let wOff = skillWidthExpanded - skillWidth
                let hOff = (exSkill?.rect.height ?? 0) - skillHeight

                if let ex = exSkill {
                    if ex.gridX < fx { fxOffset += wOff }
                    if ex.gridX < tx { txOffset += wOff }
                    if ex.gridY < fy { fyOffset += hOff }
                    if ex.gridY < ty { tyOffset += hOff }
                    if ex.gridX == fx && ex.gridY == fy {
                        initialYOffset = hOff
                        fxOffset += wOff
                    }
                    if ex.gridY == fy && connection.from.isLowered && fx != ex.gridX {
                        fyOffset += hOff
                    }
                    if ex.gridY == ty && connection.to.isLowered && tx != ex.gridX {
                        tyOffset += hOff
                    }
                    if ex.gridX == fx && ex.gridY > fy {
                        xTravelOffset += wOff
                    }
                }

                if connection.fromCategoryId > Constants.SpecificSkillCategories.beginner {
                    fxOffset += xpCostWidth
                    txOffset += xpCostWidth
                }

                let startX = x + fxOffset
                let startY = y + initialYOffset + fyOffset
                let midY = y + (lineHeight * lineMult) + dropVal + initialYOffset + fyOffset

                let color = connection.color
                let strokeStyle = StrokeStyle(lineWidth: 10)

                if fx == tx {
                    var path = Path()
                    path.move(to: CGPoint(x: startX, y: startY))
                    path.addLine(to: CGPoint(x: startX, y: midY))
                    path.addLine(to: CGPoint(x: targetX + txOffset, y: midY))
                    path.addLine(to: CGPoint(x: targetX + txOffset, y: targetY + tyOffset))
                    context.stroke(path, with: .color(color), style: strokeStyle)
                } else {
                    let signX = (targetX - x)
                    let xLoc: CGFloat = {
                        if signX < 0 {
                            return x - (skillWidth * mult) - (mult * spacingWidth)
                        } else {
                            return x + (skillWidth * (1.0 - mult)) + (mult * spacingWidth) + xTravelOffset
                        }
                    }()

                    if connection.prereqs > 1 {
                        let arcY = targetY - (spacingHeight * mult) + tyOffset
                        let elbowX = targetX - signX * (skillWidth / 4)
                        let midCircleY = targetY - (spacingHeight / 2) + tyOffset

                        var path = Path()
                        path.move(to: CGPoint(x: startX, y: startY))
                        path.addLine(to: CGPoint(x: startX, y: midY))
                        path.addLine(to: CGPoint(x: xLoc + fxOffset, y: midY))
                        path.addLine(to: CGPoint(x: xLoc + fxOffset, y: arcY))
                        path.addLine(to: CGPoint(x: elbowX + txOffset, y: arcY))
                        path.addLine(to: CGPoint(x: targetX + txOffset, y: midCircleY))
                        path.addLine(to: CGPoint(x: targetX + txOffset, y: targetY + tyOffset))

                        context.stroke(path, with: .color(color), style: strokeStyle)

                        circles[CGCircle(x: targetX + txOffset, y: midCircleY, radius: numberCircleRadius)] = connection.prereqs
                    } else {
                        let midCircleY = targetY - (spacingHeight / 2) + tyOffset

                        var path = Path()
                        path.move(to: CGPoint(x: startX, y: startY))
                        path.addLine(to: CGPoint(x: startX, y: midY))
                        path.addLine(to: CGPoint(x: xLoc + fxOffset, y: midY))
                        path.addLine(to: CGPoint(x: xLoc + fxOffset, y: midCircleY))
                        path.addLine(to: CGPoint(x: targetX + txOffset, y: midCircleY))
                        path.addLine(to: CGPoint(x: targetX + txOffset, y: targetY + tyOffset))

                        context.stroke(path, with: .color(color), style: strokeStyle)
                    }
                }
            }


            for (circle, count) in circles {
                let gradient = Gradient(colors: [lightGray, darkGray])
                let shading = GraphicsContext.Shading.linearGradient(
                    gradient,
                    startPoint: CGPoint(x: circle.x, y: circle.y - numberCircleRadius / 2),
                    endPoint: CGPoint(x: circle.x, y: circle.y + numberCircleRadius / 2)
                )

                context.fill(Path(ellipseIn: CGRect(x: circle.x - circle.radius, y: circle.y - circle.radius, width: circle.radius * 2, height: circle.radius * 2)), with: shading)

                let text = Text("\(count)")
                    .font(.system(size: textSize))
                    .foregroundColor(.white)

                context.draw(text, at: CGPoint(x: circle.x, y: circle.y), anchor: .center)
            }

            for requirement in skillRequirements {
                let rect = requirement.rect

                context.fill(Path(rect), with: .color(.black))
                context.stroke(Path(rect), with: .color(.white), lineWidth: 2)

                context.draw(requirement.text, at: CGPoint(x: rect.midX, y: rect.minY), anchor: .top)
            }


        }

    }

}

struct CGCircle: Hashable {
    let x: CGFloat
    let y: CGFloat
    let radius: CGFloat
}

struct GridSkill {
    var rect: CGRect
    let skill: FullSkillModel
    let gridX: Int
    let gridY: Int
    var expanded: Bool = false
    
    var lowered: Bool {
        return skill.prereqs.contains { $0.xpCost.intValueDefaultZero == skill.xpCost.intValueDefaultZero }
    }
}

struct SkillRequirement {
    var rect: CGRect
    let text: Text  // Use this in Canvas with attributed layout or Text()
}

struct GridLocation: Equatable, Hashable {
    let x: Int
    let y: Int
    let isLowered: Bool
}

struct GridConnection {
    let from: GridLocation
    let to: GridLocation
    var mult: Double
    var color: Color
    var prereqs: Int
    let fromCategoryId: Int

    func distance() -> Double {
        let dx = Double(to.x - from.x)
        let dy = Double(to.y - from.y)
        return (dx * dx + dy * dy).squareRoot()
    }

    func directionPriority() -> Int {
        if to.x < from.x {
            return 0
        } else if to.x == from.x {
            return 1
        } else {
            return 2
        }
    }
}

struct TappablePurchaseButton {
    let skill: CharacterModifiedSkillModel
    let rect: CGRect

    func copy() -> TappablePurchaseButton {
        return TappablePurchaseButton(skill: self.skill, rect: self.rect)
    }
}

class SkillBranch {
    let categoryId: Int
    let allSkills: [FullSkillModel]
    let skills: [FullSkillModel]
    var width: Int
    var grid: [[FullSkillModel?]]

    init(skills: [FullSkillModel], allSkills: [FullSkillModel], categoryId: Int) {
        self.categoryId = categoryId
        self.allSkills = allSkills
        self.skills = skills.sorted(by: { $0.xpCost.intValueDefaultZero < $1.xpCost.intValueDefaultZero })

        var counts = [0, 0, 0, 0, 0]
        for skill in self.skills {
            let cost = skill.xpCost.intValueDefaultZero
            if cost >= 0 && cost < counts.count {
                counts[cost] += 1
            }
        }
        self.width = counts.max() ?? 0
        self.grid = []
        organizePlacementGrid()
    }

    private func organizePlacementGrid() {
        if skills.contains(where: { $0.xpCost.intValueDefaultZero == 0 }) {
            // Free Skills
            grid = Array(repeating: [], count: 4)
            for skill in skills {
                grid[0].append(skill)
                grid[1].append(nil)
                grid[2].append(nil)
                grid[3].append(nil)
            }
        } else {
            grid = Array(repeating: [], count: 4)
            for skill in skills {
                addSkillRecursively(skill: skill, previousCost: -1)
            }
        }

        for i in 0..<grid.count {
            while grid[i].count < width {
                grid[i].append(nil)
            }
        }
    }

    private func addSkillRecursively(skill: FullSkillModel?, previousCost: Int) {
        guard let skill = skill else { return }
        if skillInGrid(skill) || skill.skillCategoryId != categoryId { return }

        let cost = skill.xpCost.intValueDefaultZero
        grid[cost - 1].append(skill)

        // Add nulls if there's a jump
        if previousCost != -1 && previousCost + 1 < cost {
            for fill in (previousCost + 1)..<cost {
                grid[fill - 1].append(nil)
            }
        }

        for postId in skill.postreqs {
            if let postSkill = getSkill(postId) {
                addSkillRecursively(skill: postSkill, previousCost: cost)
            }
        }
    }

    func skillInGrid(_ skill: FullSkillModel) -> Bool {
        for row in grid {
            if row.contains(where: { $0?.id == skill.id }) {
                return true
            }
        }
        return false
    }

    func getSkill(_ skillId: Int) -> FullSkillModel? {
        return allSkills.first(where: { $0.id == skillId })
    }

    func prettyPrintGrid() -> String {
        var output = "["
        for row in grid {
            output += "\n  ["
            for skill in row {
                if let skill = skill {
                    output += "\(skill.name) (\(skill.id)), "
                } else {
                    output += "null, "
                }
            }
            output += "],"
        }
        output += "\n]"
        return output
    }
}

class SkillGridCategory {
    let allSkills: [FullSkillModel]
    var skills: [FullSkillModel]
    let skillCategoryId: Int
    let skillCategoryName: String

    var zeroCost: [FullSkillModel] = []
    var oneCost: [FullSkillModel] = []
    var twoCost: [FullSkillModel] = []
    var threeCost: [FullSkillModel] = []
    var fourCost: [FullSkillModel] = []

    var branches: [SkillBranch] = []

    private var isEdgeCaseLeft = false
    private var isEdgeCaseRight = false
    private var edgeCaseLeft: SkillBranch?
    private var edgeCaseRight: SkillBranch?

    var width: Int

    init(skills: [FullSkillModel], skillCategoryId: Int, skillCategoryName: String, allSkills: [FullSkillModel]) {
        self.allSkills = allSkills
        self.skills = skills
        self.skillCategoryId = skillCategoryId
        self.skillCategoryName = skillCategoryName
        self.width = 0
        sortSkills()
        buildBranches()
        self.width = calculateWidth()
    }

    private func sortSkills() {
        for skill in skills {
            switch skill.xpCost.intValueDefaultZero {
            case 0: zeroCost.append(skill)
            case 1: oneCost.append(skill)
            case 2: twoCost.append(skill)
            case 3: threeCost.append(skill)
            case 4: fourCost.append(skill)
            default: zeroCost.append(skill)
            }
        }

        skills.sort { $0.xpCost.intValueDefaultZero < $1.xpCost.intValueDefaultZero }
    }

    private func buildBranches() {
        for skill in skills {
            isEdgeCaseLeft = false
            isEdgeCaseRight = false

            var skillList: [FullSkillModel] = []
            buildBranchRec(skill: skill, list: &skillList)

            if !skillList.isEmpty {
                if isEdgeCaseLeft {
                    edgeCaseLeft = SkillBranch(skills: skillList, allSkills: allSkills, categoryId: skillCategoryId)
                } else if isEdgeCaseRight {
                    edgeCaseRight = SkillBranch(skills: skillList, allSkills: allSkills, categoryId: skillCategoryId)
                } else {
                    branches.append(SkillBranch(skills: skillList, allSkills: allSkills, categoryId: skillCategoryId))
                }
            }
        }

        if let left = edgeCaseLeft {
            branches.insert(left, at: 0)
        }
        if let right = edgeCaseRight {
            branches.append(right)
        }
    }

    private func buildBranchRec(skill: FullSkillModel?, list: inout [FullSkillModel], isPrereq: Bool = false) {
        guard let skill = skill else { return }

        let isInExisting = branchesAlreadyContain(skillId: skill.id)
            || list.contains(where: { $0.id == skill.id })
            || edgeCaseLeft?.skills.contains(where: { $0.id == skill.id }) == true
            || edgeCaseRight?.skills.contains(where: { $0.id == skill.id }) == true

        if isInExisting { return }

        if skillCategoryId > skill.skillCategoryId {
            isEdgeCaseLeft = true
            return
        }
        if skillCategoryId < skill.skillCategoryId {
            isEdgeCaseRight = true
            return
        }

        list.append(skill)

        if !isPrereq {
            for postId in skill.postreqs {
                if let post = getSkill(skillId: postId) {
                    buildBranchRec(skill: post, list: &list)
                }
            }
        }

        for prereq in skill.prereqs {
            buildBranchRec(skill: prereq, list: &list, isPrereq: true)
        }
    }

    private func getSkill(skillId: Int) -> FullSkillModel? {
        return allSkills.first(where: { $0.id == skillId })
    }

    private func branchesAlreadyContain(skillId: Int) -> Bool {
        return branches.contains(where: { $0.skills.contains(where: { $0.id == skillId }) })
    }

    private func calculateWidth() -> Int {
        return branches.reduce(0) { $0 + $1.width }
    }
}


