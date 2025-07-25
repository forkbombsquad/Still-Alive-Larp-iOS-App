//
//  LocalDataManagerModels.swift
//  StillAliveLarp
//
//  Created by Rydge Craker on 7/25/25.
//

struct LDAwardModels: CustomCodeable {
    let playerAwards: [Int : [AwardModel]]
    let characterAwards: [Int : [AwardModel]]
}
