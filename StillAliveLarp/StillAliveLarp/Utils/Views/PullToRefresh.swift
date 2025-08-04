//
//  PullToRefresh.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/19/23.
//

import SwiftUI

//To use this view there MUST be an accompanying call to `.coordinateSpace(name: "pullToRefresh")` in
// the parent view where "pullToRefresh" is the coordinate space name that is passed in to this struct.
// Example:
// ScrollView {
//     PullToRefresh(coordinateSpaceName: "pullToRefresh", spinnerOffsetY: -100, pullDownDistance: 150) {
//         //Do refresh stuff here
//     }
// }
// .coordinateSpace(name: "pullToRefresh")

struct PullToRefresh: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    //The coordinate space for the Geometry Reader to operate in
    var coordinateSpaceName: String

    //The vertical offset of the spinner (the spinner is always centered horizontally)
    var spinnerOffsetY: CGFloat

    //The distance the user needs to pull down to trigger the spinner visual indicator and the `onRefresh` closure
    var pullDownDistance: CGFloat

    //The closure to be executed
    var onRefresh: ()->Void

    @State var needRefresh: Bool = false

    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: .named(coordinateSpaceName)).minY > (spinnerOffsetY + pullDownDistance)) {
                Spacer()
                    .onAppear {
                        needRefresh = true
                    }
            } else if (geo.frame(in: .named(coordinateSpaceName)).minY < 0) {
                Spacer()
                    .onAppear {
                        if needRefresh {
                            needRefresh = false
                            onRefresh()
                        }
                    }
            }
            HStack {
                Spacer()
                if needRefresh {
                    ProgressView().scaleEffect(CGSize(width: 1.25, height: 1.25))
                }
                Spacer()
            }
        }
        .padding(.top, spinnerOffsetY)
    }
}
