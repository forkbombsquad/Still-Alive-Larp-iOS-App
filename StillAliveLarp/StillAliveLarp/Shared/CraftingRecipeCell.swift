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

                    // Required Skill Column - give it 40% width and allow wrapping
                    VStack {
                        Text("Required Skill:")
                            .font(.system(size: 16, weight: .bold))
                            .multilineTextAlignment(.center)
                        if let skill = recipe.requiredSkill {
                            Text(skill.name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(skillTypeColor(skill.skillTypeId))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text("*")
                                .font(.system(size: 18))
                                .multilineTextAlignment(.center)
                        }
                    }
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

                // Get materials list from the recipe model
                let matList = recipe.craftingRecipe.getMaterialsList()

                if matList.isEmpty {
                    Text("-")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                } else {
                    // Resolve recipe references with actual names from otherRecipeReferences
                    let resolvedMats = matList.map { mat -> MaterialItem in
                        if mat.isRecipeReference, let refId = mat.recipeId {
                            if let fullRef = recipe.otherRecipeReferences.first(where: { $0.id == refId }) {
                                return MaterialItem(quantity: mat.quantity, name: fullRef.getDisplayName(), recipeId: refId, isRecipeReference: true, isFood: mat.isFood)
                            }
                        }
                        return mat
                    }

                    // Get distributed columns
                    let columns = getMaterialColumns(resolvedMats)

                    HStack(spacing: 4) {
                        VStack {
                            ForEach(columns.col1) { material in
                                materialText(material)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        VStack {
                            ForEach(columns.col2) { material in
                                materialText(material)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        VStack {
                            ForEach(columns.col3) { material in
                                materialText(material)
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

    private func materialText(_ material: MaterialItem) -> some View {
        let text = material.isRecipeReference || material.isFood
            ? "\(material.quantity) \(material.name)"
            : "\(material.quantity) \(material.name)"
        let font: Font = material.isRecipeReference
            ? .system(size: 16, weight: .bold)
            : .system(size: 16)

        return Text(text)
            .font(font)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .padding(4)
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

    // Helper to distribute materials across 3 columns
    private func getMaterialColumns(_ matList: [MaterialItem]) -> (col1: [MaterialItem], col2: [MaterialItem], col3: [MaterialItem]) {
        var col1 = [MaterialItem]()
        var col2 = [MaterialItem]()
        var col3 = [MaterialItem]()
        var column = 2

        for mat in matList {
            switch column {
            case 1: col1.append(mat)
            case 2: col2.append(mat)
            case 3: col3.append(mat)
            default: break
            }
            column -= 1
            if column == 0 { column = 3 }
        }

        return (col1, col2, col3)
    }
}
