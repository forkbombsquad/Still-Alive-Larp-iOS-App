//
//  ProfileImageModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/18/24.
//

import SwiftUI
import Foundation

struct ProfileImageModel: CustomCodeable {
    let id: Int
    let playerId: Int
    let image: String

    var uiImage: UIImage? {
        guard let data = Data(base64Encoded: image.replacingOccurrences(of: "\n", with: "")) else { return nil }
        return UIImage(data: data)
    }
}

struct ProfileImageCreateModel: CustomCodeable {
    let playerId: Int
    let image: String
}

struct ProfileImageListModel: CustomCodeable {
    var profileImages: [ProfileImageModel]
}
