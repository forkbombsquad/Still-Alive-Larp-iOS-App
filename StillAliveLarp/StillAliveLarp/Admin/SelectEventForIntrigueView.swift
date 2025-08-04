//
//  SelectEventForIntrigueView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/26/23.
//

import SwiftUI

struct SelectEventForIntrigueView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let events: [EventModel]
    @State var loading: Bool = false

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    VStack {
                        Text("Select Event\nFor Intrigue Management")
                            .font(.system(size: 32, weight: .bold))
                            .frame(alignment: .center)
                            .fixedSize(horizontal: false, vertical: true)
                        ForEach(events) { event in
                            NavArrowView(title: event.title, loading: $loading) { _ in
                                AddEditEventIntrigueView(event: event)
                            }
                        }
                    }
                }
            }
        }.padding(16)
        .background(Color.lightGray)
    }
}

#Preview {
    DataManager.shared.setDebugMode(true)
    let md = getMockData()
    return SelectEventForIntrigueView(_dm: dm, events: md.events.events)
}
