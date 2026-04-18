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
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        LoadingLayoutView {
                            VStack {
                                globalCreateTitleView("Crafting Recipes", DM: DM)
                                // Category buttons
                                ForEach(getCategories(), id: \.self) { category in
                                    NavArrowView(title: category) { _ in
                                        CraftingRecipesListView(
                                            recipes: getRecipesForCategory(category).sorted { $0.getDisplayName().caseInsensitiveCompare($1.getDisplayName()) == .orderedAscending },
                                            categoryName: category
                                        )
                                    }
                                }
                                // "All Recipes" button at bottom
                                NavArrowViewBlue(title: "All Recipes") {
                                    CraftingRecipesListView(
                                        recipes: DM.craftingRecipes.sorted { $0.getDisplayName().caseInsensitiveCompare($1.getDisplayName()) == .orderedAscending },
                                        categoryName: "All"
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.lightGray)
    }

    func getCategories() -> [String] {
        return Array(Set(DM.craftingRecipes.map { $0.category }.sorted()))
    }

    func getRecipesForCategory(_ category: String) -> [FullCraftingRecipeModel] {
        return DM.craftingRecipes.filter { $0.category == category }
    }
}

//#Preview {
//    CraftingRecipesCategoriesView()
//        .environmentObject(DataManager.shared)
//}
