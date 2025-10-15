//
//  CheckInOutBarcodeModel.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/20/23.
//

import Foundation


struct CheckInOutBarcodeModel: CustomCodeable {

    var playerId: Int
    var characterId: Int?
    var eventId: Int

}
