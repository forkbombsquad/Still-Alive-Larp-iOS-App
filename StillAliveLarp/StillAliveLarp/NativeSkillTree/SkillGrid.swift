import SwiftUI

class SkillGrid {
    let personal: Bool
    let allowPurchase: Bool

    let skills: [FullSkillModel]
    private var purchaseableSkills: [CharacterModifiedSkillModel] = []
    private let skillCategories: [SkillCategoryModel]
    var gridCategories: [SkillGridCategory] = []
    var trueGrid: [GridSkill] = []

    var fullGrid: [[FullSkillModel?]] = []
    var gridConnections: [GridConnection] = []

    init(skills: [FullSkillModel], skillCategories: [SkillCategoryModel], personal: Bool, allowPurchase: Bool) {
        self.skills = skills
        self.skillCategories = skillCategories
        self.personal = personal
        self.allowPurchase = allowPurchase

        self.calculateWidthAndHeightOfGridCategories()
        self.orderCategories()
        self.fullGrid = self.calculateFullGrid()
        self.trueGrid = self.calculateTrueGrid()
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
        var gridSkills: [GridSkill] = []

        for (xpCost, row) in fullGrid.enumerated() {
            for (skillIndex, skill) in row.enumerated() {
                guard let skill = skill else { continue }

                gridSkills.append(GridSkill(skill: skill, gridX: skillIndex, gridY: xpCost, expanded: false))
            }
        }

        return gridSkills
    }

}

struct GridSkill: Identifiable {
    var id: Int {
        return skill.id
    }
    
    let skill: FullSkillModel
    let gridX: Int
    let gridY: Int
    var expanded: Bool = false
    
    var lowered: Bool {
        return skill.prereqs.contains { $0.xpCost.intValueDefaultZero == skill.xpCost.intValueDefaultZero }
    }
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


