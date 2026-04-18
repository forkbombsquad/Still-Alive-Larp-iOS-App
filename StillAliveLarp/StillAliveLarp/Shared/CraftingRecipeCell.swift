//
//  CraftingRecipeCell.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/17/26.
//

import SwiftUI

struct CraftingRecipeCell: View {

    let recipe: FullCraftingRecipeModel

    init(recipe: FullCraftingRecipeModel) {
        self.recipe = recipe
    }

    var body: some View {
        CardView {
            VStack {
                // Recipe Name - Centered, Bold
                Text(recipe.getDisplayName())
                    .font(.system(size: 20, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                // Divider 1
                Divider()
                    .frame(height: 1)
                    .padding(.horizontal, 48)

                // Makes | Crafting Time | Required Skill - 3 Column Row
                HStack(alignment: .top) {
                    // Makes Column
                    VStack {
                        Text("Makes:")
                            .font(.system(size: 16, weight: .bold))
                            .multilineTextAlignment(.center)
                        Text("x\(recipe.craftingRecipe.numProduced)")
                            .font(.system(size: 18))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)

                    // Crafting Time Column
                    VStack {
                        Text("Crafting Time:")
                            .font(.system(size: 16, weight: .bold))
                            .multilineTextAlignment(.center)
                        Text(recipe.getCraftingTimeText())
                            .font(.system(size: 18))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)

                    // Required Skill Column - give it more space
                    VStack {
                        Text("Required Skill:")
                            .font(.system(size: 16, weight: .bold))
                            .multilineTextAlignment(.center)
                        if let skill = recipe.requiredSkill {
                            Text(skill.name)
                                .font(.system(size: 18))
                                .foregroundColor(skillTypeColor(skill.skillTypeId))
                                .multilineTextAlignment(.center)
                                .fixedSize()
                        } else {
                            Text("*")
                                .font(.system(size: 18))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(width: 120)
                }
                .padding(.horizontal, 8)

                // Divider 2
                Divider()
                    .frame(height: 1)
                    .padding(.horizontal, 48)

// Materials Section Header
                Text("Materials:")
                    .font(.system(size: 16, weight: .bold))
                    .multilineTextAlignment(.center)

                // Show all material fields directly (wood, metal, cloth, tech, medical, casing)
                let allMaterials: [(String, Int)] = [
                    ("Wood", recipe.craftingRecipe.wood),
                    ("Metal", recipe.craftingRecipe.metal),
                    ("Cloth", recipe.craftingRecipe.cloth),
                    ("Tech Supplies", recipe.craftingRecipe.tech),
                    ("Medical Supplies", recipe.craftingRecipe.medical),
                    ("Casings", recipe.craftingRecipe.casing)
                ].filter { $0.1 > 0 }

                if allMaterials.isEmpty {
                    Text("-")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                } else {
                    // Split into 3 columns
                    let col1 = stride(from: 0, to: allMaterials.count, by: 3).map { allMaterials[$0] }
                    let col2 = stride(from: 1, to: allMaterials.count, by: 3).map { allMaterials[$0] }
                    let col3 = stride(from: 2, to: allMaterials.count, by: 3).map { allMaterials[$0] }

                    HStack(spacing: 4) {
                        VStack {
                            ForEach(col1, id: \.0) { name, qty in
                                Text("\(qty) \(name)")
                                    .font(.system(size: 16))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        VStack {
                            ForEach(col2, id: \.0) { name, qty in
                                Text("\(qty) \(name)")
                                    .font(.system(size: 16))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        VStack {
                            ForEach(col3, id: \.0) { name, qty in
                                Text("\(qty) \(name)")
                                    .font(.system(size: 16))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 8)
                }

                // Description / Notes (if exists)
                if let desc = recipe.desc, !desc.isEmpty {
                    Divider()
                        .frame(height: 1)
                        .padding(.horizontal, 48)
                        .padding(.top, 8)

                    Text("Notes:")
                        .font(.system(size: 16, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text(desc)
                        .font(.system(size: 14))
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // Helper to distribute materials across 3 columns
    private func materialMatchesColumn(_ material: MaterialItem, column: Int, total: Int) -> Bool {
        let materialsList = recipe.craftingRecipe.getMaterialsList()
        let perColumn = max(1, (materialsList.count + 2) / 3)
        let startIndex = (column - 1) * perColumn
        let endIndex = min(column * perColumn, materialsList.count)

        if let index = materialsList.firstIndex(where: { $0.id == material.id }) {
            return index >= startIndex && index < endIndex
        }
        return false
    }

    private func materialText(_ material: MaterialItem) -> some View {
        let text = material.isRecipeReference || material.isFood
            ? "\(material.quantity) \(material.name)"
            : "\(material.quantity) \(material.name)"
        let font: Font = material.isRecipeReference || material.isFood
            ? .system(size: 16, weight: .bold)
            : .system(size: 16)

        return Text(text)
            .font(font)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
    }

    private func skillTypeColor(_ skillTypeId: Int) -> Color {
        switch skillTypeId {
        case Constants.SkillTypes.combat:
            return .brightRed
        case Constants.SkillTypes.profession:
            return .green
        case Constants.SkillTypes.talent:
            return .blue
        default:
            return .blue
        }
    }
}
