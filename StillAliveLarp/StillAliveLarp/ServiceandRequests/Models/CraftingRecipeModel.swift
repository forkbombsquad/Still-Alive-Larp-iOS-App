//
//  CraftingRecipeModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/17/26.
//

import Foundation

// MARK: - JSON Models for parsing otherRequiredItemIds

struct CraftingRecipeOtherRequiredItemJsonModel: CustomCodeable {
    let id: Int
    let num: Int

    init(id: Int, num: Int) {
        self.id = id
        self.num = num
    }
}

struct CraftingRecipeOtherRequiredItemsJsonModel: CustomCodeable {
    let otherItemIds: [CraftingRecipeOtherRequiredItemJsonModel]?
    let foods: [[String: Int]]?

    init(otherItemIds: [CraftingRecipeOtherRequiredItemJsonModel]?, foods: [[String: Int]]?) {
        self.otherItemIds = otherItemIds
        self.foods = foods
    }

    func getFoodMaterials() -> [MaterialItem] {
        var items = [MaterialItem]()
        if let foods = foods {
            for map in foods {
                for (name, quantity) in map {
                    items.append(MaterialItem(quantity: quantity, name: name, isFood: true))
                }
            }
        }
        return items
    }
}

// MARK: - MaterialItem

struct MaterialItem: Identifiable {
    let id = UUID()
    let quantity: Int
    let name: String
    var recipeId: Int?
    var isRecipeReference: Bool
    var isFood: Bool

    init(quantity: Int, name: String, recipeId: Int? = nil, isRecipeReference: Bool = false, isFood: Bool = false) {
        self.quantity = quantity
        self.name = name
        self.recipeId = recipeId
        self.isRecipeReference = isRecipeReference
        self.isFood = isFood
    }
}

// MARK: - CraftingRecipeModel

struct CraftingRecipeModel: CustomCodeable, Identifiable {
    let id: Int
    let name: String
    let baseRecipeId: Int?
    let skillId: Int?
    let numProduced: Int
    let category: String
    let craftingTime: Double
    let wood: Int
    let metal: Int
    let cloth: Int
    let tech: Int
    let medical: Int
    let casing: Int
    let otherRequiredItemIds: String?
    let desc: String?

    // MARK: - Parsed JSON Helpers

    var otherRequiredItemsJsonModel: CraftingRecipeOtherRequiredItemsJsonModel? {
        guard let jsonString = otherRequiredItemIds, !jsonString.isEmpty else { return nil }
        return jsonString.data(using: .utf8)?.toJsonObject()
    }

    // MARK: - Helper Methods

    func getMaterialsList() -> [MaterialItem] {
        var matList = [MaterialItem]()

        if wood > 0 {
            matList.append(MaterialItem(quantity: wood, name: "Wood"))
        }
        if metal > 0 {
            matList.append(MaterialItem(quantity: metal, name: "Metal"))
        }
        if cloth > 0 {
            matList.append(MaterialItem(quantity: cloth, name: "Cloth"))
        }
        if tech > 0 {
            matList.append(MaterialItem(quantity: tech, name: "Tech Supplies"))
        }
        if medical > 0 {
            matList.append(MaterialItem(quantity: medical, name: "Medical Supplies"))
        }
        if casing > 0 {
            matList.append(MaterialItem(quantity: casing, name: "Casings"))
        }

        // Other recipe items (these should be bolded)
        if let otherItems = otherRequiredItemsJsonModel?.otherItemIds {
            for item in otherItems {
                matList.append(MaterialItem(quantity: item.num, name: "Recipe \(item.id)", recipeId: item.id, isRecipeReference: true))
            }
        }

        // Foods - each food item should be listed separately
        let foods = otherRequiredItemsJsonModel?.getFoodMaterials() ?? []
        for food in foods {
            matList.append(food)
        }

        return matList
    }

    func isAlternate() -> Bool {
        return baseRecipeId != nil && baseRecipeId != -1
    }

    func getOtherRecipeIds() -> [Int] {
        return otherRequiredItemsJsonModel?.otherItemIds?.map { $0.id } ?? []
    }
}

// MARK: - FullCraftingRecipeModel

struct FullCraftingRecipeModel: CustomCodeable, Identifiable {
    let craftingRecipe: CraftingRecipeModel
    let requiredSkill: FullSkillModel?
    private let baseRecipe: CraftingRecipeModel?
    let otherRecipeReferences: [FullCraftingRecipeModel]

    var category: String { craftingRecipe.category }
    var id: Int { craftingRecipe.id }
    var name: String { craftingRecipe.name }
    var desc: String? { craftingRecipe.desc }
    var craftingTime: Double { craftingRecipe.craftingTime }
    var baseRecipeId: Int? { baseRecipe?.id }
    
    init(craftingRecipe: CraftingRecipeModel, requiredSkill: FullSkillModel?, baseRecipe: CraftingRecipeModel?, otherRecipeReferences: [FullCraftingRecipeModel]) {
        self.craftingRecipe = craftingRecipe
        self.requiredSkill = requiredSkill
        self.baseRecipe = baseRecipe
        self.otherRecipeReferences = otherRecipeReferences
    }

    func getDisplayName() -> String {
        if isAlternate() && baseRecipe != nil {
            return "\(baseRecipe!.name) (\(self.name))"
        } else {
            return self.name
        }
    }

    func getCraftingTimeText() -> String {
        let time = craftingTime
        if time < 0 {
            return "*see Notes"
        } else if time < 1 {
            return "\(Int(time * 60)) sec"
        } else {
            return "\(Int(time)) min"
        }
    }

    func isAlternate() -> Bool {
        return baseRecipeId != nil && baseRecipeId != -1
    }

    func containedInSearch(searchText: String) -> Bool {
        let lowercasedSearch = searchText.lowercased()
        if getDisplayName().lowercased().contains(lowercasedSearch) {
            return true
        } else if category.lowercased().contains(lowercasedSearch) {
            return true
        } else if (desc ?? "").lowercased().contains(lowercasedSearch) {
            return true
        }
        return false
    }
}

// MARK: - CraftingRecipeListModel

struct CraftingRecipeListModel: CustomCodeable {
    let craftingRecipes: [CraftingRecipeModel]

    init(craftingRecipes: [CraftingRecipeModel]) {
        self.craftingRecipes = craftingRecipes
    }
}
