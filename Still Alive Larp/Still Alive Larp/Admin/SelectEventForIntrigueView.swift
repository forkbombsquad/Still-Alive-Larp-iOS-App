//
//  SelectEventForIntrigueView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/26/23.
//

import SwiftUI

struct SelectEventForIntrigueView: View {
    @ObservedObject private var _dm = DataManager.shared

    let events: [EventModel]
    @State var loading: Bool = false

    var body: some View {
        VStack {
            ScrollView {
                GeometryReader { gr in
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
