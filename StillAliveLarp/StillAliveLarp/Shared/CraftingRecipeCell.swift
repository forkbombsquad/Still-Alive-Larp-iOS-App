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
                HStack {
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

                    // Required Skill Column
                    VStack {
                        Text("Required Skill:")
                            .font(.system(size: 16, weight: .bold))
                            .multilineTextAlignment(.center)
                        if let skill = recipe.requiredSkill {
                            Text(skill.name)
                                .font(.system(size: 18))
                                .foregroundColor(skillTypeColor(skill.skillTypeId))
                                .multilineTextAlignment(.center)
                        } else {
                            Text("*")
                                .font(.system(size: 18))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
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

                // 3-Column Materials Layout
                let materialsList = recipe.craftingRecipe.getMaterialsList()
                let col1Materials = materialsList.filter { materialMatchesColumn($0, column: 1, total: materialsList.count) }
                let col2Materials = materialsList.filter { materialMatchesColumn($0, column: 2, total: materialsList.count) }
                let col3Materials = materialsList.filter { materialMatchesColumn($0, column: 3, total: materialsList.count) }

                HStack(spacing: 4) {
                    // Column 1
                    VStack {
                        ForEach(col1Materials) { material in
                            materialText(material)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // Column 2
                    VStack {
                        ForEach(col2Materials) { material in
                            materialText(material)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // Column 3
                    VStack {
                        ForEach(col3Materials) { material in
                            materialText(material)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 8)

                // Description / Notes (if exists)
                if let desc = recipe.desc, !desc.isEmpty {
                    Divider()
                        .frame(height: 1)
                        .padding(.horizontal, 48)
                        .padding(.top, 8)

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
