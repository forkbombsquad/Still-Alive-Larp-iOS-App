//
//  BarcodeGenerator.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/20/23.
//

import Foundation
import CoreImage.CIFilterBuiltins
import SwiftUI

struct BarcodeGenerator {

    private static let errorImage = UIImage(systemName: "xmark.circle") ?? UIImage()

    static func generateQrCodeFromModel(_ model: CustomCodeable) -> UIImage {
        guard let data = model.toJsonString()?.compress() else {
            return errorImage
        }
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = data

        guard let outputImage = filter.outputImage, let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return errorImage
        }
        return UIImage(cgImage: cgImage)
    }

    static func generateCheckInBarcode(_ model: PlayerCheckInBarcodeModel) -> UIImage {
        return generateQrCodeFromModel(model)
    }

    static func generateCheckOutBarcode(_ model: PlayerCheckOutBarcodeModel) -> UIImage {
        return generateQrCodeFromModel(model)
    }

}
