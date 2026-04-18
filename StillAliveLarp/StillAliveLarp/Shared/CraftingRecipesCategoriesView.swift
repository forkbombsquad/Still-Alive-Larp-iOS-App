//
//  CraftingRecipesCategoriesView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/17/26.
//

import SwiftUI

struct CraftingRecipesCategoriesView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    var body: some View {
        VStack(spacing: 0) {
            // Header
            globalCreateTitleView("Crafting Recipes", DM: DM)

            // Loading wrapper
            LoadingLayoutView {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        // Get unique categories from recipes
                        let categories = getCategories()
                        let counts = getCategoryCounts()

                        // Category buttons
                        ForEach(categories, id: \.self) { category in
                            let count = counts[category] ?? 0
                            NavArrowView(title: "\(category) (\(count))") { _ in
                                CraftingRecipesListView(
                                    recipes: getRecipesForCategory(category).sorted { $0.getDisplayName().caseInsensitiveCompare($1.getDisplayName()) == .orderedAscending },
                                    categoryName: category
                                )
                            }
                        }

                        // Divider
                        Divider()
                            .padding(.vertical, 16)

                        // "All Recipes" button at bottom
                        NavArrowViewBlue(title: "All Recipes") {
                            CraftingRecipesListView(
                                recipes: DM.craftingRecipes.sorted { $0.getDisplayName().caseInsensitiveCompare($1.getDisplayName()) == .orderedAscending },
                                categoryName: "All"
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .background(Color.lightGray)
    }

    func getCategories() -> [String] {
        return DM.craftingRecipes
            .map { $0.category }
            .sorted()
    }

    func getCategoryCounts() -> [String: Int] {
        var counts = [String: Int]()
        for recipe in DM.craftingRecipes {
            let category = recipe.category
            counts[category, default: 0] += 1
        }
        return counts
    }

    func getRecipesForCategory(_ category: String) -> [FullCraftingRecipeModel] {
        return DM.craftingRecipes.filter { $0.category == category }
    }
}

//#Preview {
//    CraftingRecipesCategoriesView()
//        .environmentObject(DataManager.shared)
//}
