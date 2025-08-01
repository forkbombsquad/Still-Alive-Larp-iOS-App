//
//  CampStatusModel.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 8/1/25.
//

import Foundation

struct CampStatusModel: CustomCodeable {
    let id: Int
    let campFortificationJson: String
    
    init(id: Int, campFortificationJson: String) {
        self.id = id
        self.campFortificationJson = campFortificationJson
    }
    
    init(id: Int, campFortifications: [CampFortifications]) {
        self.id = id
        self.campFortificationJson = campFortifications(campFortifications: campFortifications).toJsonString() ?? ""
    }
    
    var campFortifications: [CampFortification] {
        let cf: CampFortifications? = gearJson.data(using: .utf8)?.toJsonObject()
        return cf?.campFortifications ?? []
    }
}

// TODO


 data class CampFortification(
     @JsonProperty("ring") var ring: Int,
     @JsonProperty("fortifications") var fortifications: List<Fortification>
 ) : Serializable

 data class Fortification(
     @JsonProperty("type") var type: String,
     @JsonProperty("health") var health: Int
 ) : Serializable {

     constructor(type: FortificationType, health: Int): this(type.text, health)

     val fortificationType: FortificationType
         get() {
             return FortificationType.getFortificationType(type)
         }

     enum class FortificationType(val text: String) {
         LIGHT("LIGHT"),
         MEDIUM("MEDIUM"),
         HEAVY("HEAVY"),
         ADVANCED("ADVANCED"),
         MILITARY_GRADE("MILITARY GRADE");

         fun getMaxHealth(): Int {
             return when (this) {
                 LIGHT -> 5
                 MEDIUM -> 10
                 HEAVY -> 15
                 ADVANCED -> 20
                 MILITARY_GRADE -> 30
             }
         }

         companion object {

             fun getFortificationType(value: String): FortificationType {
                 return FortificationType.values().firstOrNull { it.text == value } ?: LIGHT
             }

         }
     }

 }

 data class CampFortifications(@JsonProperty("campFortifications") val campFortifications: List<CampFortification>
 ) : Serializable
  617 changes: 445 additions & 172 deletions617
 */
