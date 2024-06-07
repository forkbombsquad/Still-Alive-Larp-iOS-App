//
//  DownloadedImageView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 6/6/24.
//

import SwiftUI

struct DownloadedImageView: View {

    @State var image: UIImage

    var body: some View {
        ZoomableScrollView {
            Image(uiImage: image).resizable().aspectRatio(contentMode: .fit)
        }
        .background(Color.lightGray)
    }
}
