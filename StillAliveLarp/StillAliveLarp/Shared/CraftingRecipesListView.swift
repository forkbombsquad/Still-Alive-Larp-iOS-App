//
//  CraftingRecipesListView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/17/26.
//

import SwiftUI

struct CraftingRecipesListView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let recipes: [FullCraftingRecipeModel]
    let categoryName: String

    @State var searchText: String = ""
    @State var showCanCraft: Bool = false
    @State var showHaveMaterials: Bool = false

    init(recipes: [FullCraftingRecipeModel], categoryName: String) {
        self.recipes = recipes
        self.categoryName = categoryName
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            globalCreateTitleView(categoryName == "All" ? "Crafting Recipes" : categoryName, DM: DM)

            // Search Bar
            TextField("Search", text: $searchText)
                .padding([.leading, .trailing], 16)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            // Checkboxes
            VStack(alignment: .leading, spacing: 4) {
                Toggle("Only Show Recipes I Can Craft", isOn: $showCanCraft)
                    .padding(.horizontal, 16)
                    .onChange(of: showCanCraft) { _ in
                        // When unchecking "Can Craft", also uncheck "Have Materials"
                        if !showCanCraft {
                            showHaveMaterials = false
                        }
                    }

                if showCanCraft {
                    Toggle("Only Show Recipes I Have The Materials For", isOn: $showHaveMaterials)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.top, 8)

            // Recipe List
            let filteredRecipes = getFilteredRecipes().sorted { $0.getDisplayName().caseInsensitiveCompare($1.getDisplayName()) == .orderedAscending }
            if filteredRecipes.isEmpty {
                Spacer()
                Text("No recipes found")
                    .font(.system(size: 18))
                    .foregroundColor(.darkGray)
                Spacer()
            } else {
                List() {
                    ForEach(filteredRecipes) { recipe in
                        CraftingRecipeCell(recipe: recipe)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.lightGray)
            }
        }
        .background(Color.lightGray)
    }

    func getFilteredRecipes() -> [FullCraftingRecipeModel] {
        var result = recipes

        // Filter by search text
        if !searchText.trimmed.isEmpty {
            result = result.filter { $0.containedInSearch(searchText: searchText) }
        }

        // Filter by "Only Show Recipes I Can Craft"
        if showCanCraft {
            let activeCharacter = DM.getActiveCharacter()
            result = result.filter { recipe in
                guard let skillId = recipe.craftingRecipe.skillId else { return false }
                return activeCharacter?.allPurchasedSkills().contains { $0.id == skillId } ?? false
            }
        }

        // Filter by "Only Show Recipes I Have Materials For"
        if showCanCraft && showHaveMaterials {
            let activeCharacter = DM.getActiveCharacter()
            result = result.filter { recipe in
                guard let character = activeCharacter else { return false }
                // Check if character has required materials in gear
                // This is a simplified version - full implementation would check actual inventory
                return true // Placeholder - requires gear inventory check
            }
        }

        return result
    }
}

//#Preview {
//    let md = MockDataManagement.allMockData[0]
//    return CraftingRecipesListView(recipes: md.fullCraftingRecipes(), categoryName: "All")
//        .environmentObject(DataManager.shared)
//}