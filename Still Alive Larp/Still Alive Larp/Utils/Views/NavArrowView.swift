//
//  NavArrowView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 12/23/22.
//

import SwiftUI

struct NavArrowView<Content: View>: View {
    @ObservedObject private var _dm = DataManager.shared

    var attachedObject: Any?

    var title: String
    var destinationView: Content
    @Binding var loading: Bool
    @Binding var notificationBubbleText: String

    init(title: String, loading: Binding<Bool> = Binding(get: { false }, set: { _ in }), notificationBubbleText: Binding<String> = Binding(get: { "" }, set: { _ in }), attachedObject: Any? = nil, @ViewBuilder content: (_ attachedObject: Any?) -> Content) {
        self.title = title
        self._loading = loading
        self._notificationBubbleText = notificationBubbleText
        self.attachedObject = attachedObject
        self.destinationView = content(self.attachedObject)
    }

    var body: some View {
        if loading {
            BlackCardView {
                HStack {
                    Text(title).font(.system(size: 18)).fontWeight(.bold).foregroundColor(.black)
                    Spacer()
                    if !notificationBubbleText.isEmpty {
                        Text(notificationBubbleText)
                            .foregroundColor(.brightRed)
                            .padding(12)
                            .overlay(
                                Circle()
                                    .stroke(Color.brightRed, lineWidth: 2)
                            )
                        Spacer()
                    }
                    ProgressView()
                }
            }
        } else {
            NavigationLink(destination: destinationView) {
                BlackCardView {
                    HStack {
                        Text(title).font(.system(size: 18)).fontWeight(.bold).foregroundColor(.black)
                        Spacer()
                        if !notificationBubbleText.isEmpty {
                            Text(notificationBubbleText)
                                .foregroundColor(.brightRed)
                                .padding(12)
                                .overlay(
                                    Circle()
                                        .stroke(Color.brightRed, lineWidth: 2)
                                )
                            Spacer()
                        }
                        Image(systemName: "arrow.right").foregroundColor(Color.black)
                    }
                }
            }
        }
    }
}

struct NavArrowViewGreen<Content: View>: View {
    @ObservedObject private var _dm = DataManager.shared

    var title: String
    var destinationView: Content
    @Binding var loading: Bool
    @Binding var notificationBubbleText: String

    init(title: String, loading: Binding<Bool> = Binding(get: { false }, set: { _ in }), notificationBubbleText: Binding<String> = Binding(get: { "" }, set: { _ in }), @ViewBuilder content: () -> Content) {
        self.title = title
        self._loading = loading
        self._notificationBubbleText = notificationBubbleText
        self.destinationView = content()
    }

    var body: some View {
        if loading {
            GreenCardView {
                HStack {
                    Text(title).font(.system(size: 18)).fontWeight(.bold).foregroundColor(.black)
                    Spacer()
                    if !notificationBubbleText.isEmpty {
                        Text(notificationBubbleText)
                            .foregroundColor(.brightRed)
                            .padding(12)
                            .overlay(
                                Circle()
                                    .stroke(Color.brightRed, lineWidth: 2)
                            )
                        Spacer()
                    }
                    ProgressView()
                }
            }
        } else {
            NavigationLink(destination: destinationView) {
                GreenCardView {
                    HStack {
                        Text(title).font(.system(size: 18)).fontWeight(.bold).foregroundColor(.black)
                        Spacer()
                        if !notificationBubbleText.isEmpty {
                            Text(notificationBubbleText)
                                .foregroundColor(.brightRed)
                                .padding(12)
                                .overlay(
                                    Circle()
                                        .stroke(Color.brightRed, lineWidth: 2)
                                )
                            Spacer()
                        }
                        Image(systemName: "arrow.right").foregroundColor(Color.black)
                    }
                }
            }
        }
    }
}

struct NavArrowViewBlue<Content: View>: View {
    @ObservedObject private var _dm = DataManager.shared

    var title: String
    var destinationView: Content
    @Binding var loading: Bool
    @Binding var notificationBubbleText: String

    init(title: String, loading: Binding<Bool> = Binding(get: { false }, set: { _ in }), notificationBubbleText: Binding<String> = Binding(get: { "" }, set: { _ in }), @ViewBuilder content: () -> Content) {
        self.title = title
        self._loading = loading
        self._notificationBubbleText = notificationBubbleText
        self.destinationView = content()
    }

    var body: some View {
        if loading {
            BlueCardView {
                HStack {
                    Text(title).font(.system(size: 18)).fontWeight(.bold).foregroundColor(.black)
                    Spacer()
                    if !notificationBubbleText.isEmpty {
                        Text(notificationBubbleText)
                            .foregroundColor(.brightRed)
                            .padding(12)
                            .overlay(
                                Circle()
                                    .stroke(Color.brightRed, lineWidth: 2)
                            )
                        Spacer()
                    }
                    ProgressView()
                }
            }
        } else {
            NavigationLink(destination: destinationView) {
                BlueCardView {
                    HStack {
                        Text(title).font(.system(size: 18)).fontWeight(.bold).foregroundColor(.black)
                        Spacer()
                        if !notificationBubbleText.isEmpty {
                            Text(notificationBubbleText)
                                .foregroundColor(.brightRed)
                                .padding(12)
                                .overlay(
                                    Circle()
                                        .stroke(Color.brightRed, lineWidth: 2)
                                )
                            Spacer()
                        }
                        Image(systemName: "arrow.right").foregroundColor(Color.black)
                    }
                }
            }
        }
    }
}

struct NavArrowViewRed<Content: View>: View {
    @ObservedObject private var _dm = DataManager.shared

    var title: String
    var destinationView: Content
    @Binding var loading: Bool
    @Binding var notificationBubbleText: String

    init(title: String, loading: Binding<Bool> = Binding(get: { false }, set: { _ in }), notificationBubbleText: Binding<String> = Binding(get: { "" }, set: { _ in }), @ViewBuilder content: () -> Content) {
        self.title = title
        self._loading = loading
        self._notificationBubbleText = notificationBubbleText
        self.destinationView = content()
    }

    var body: some View {
        if loading {
            RedCardView {
                HStack {
                    Text(title).font(.system(size: 18)).fontWeight(.bold).foregroundColor(.black)
                    Spacer()
                    if !notificationBubbleText.isEmpty {
                        Text(notificationBubbleText)
                            .foregroundColor(.brightRed)
                            .padding(12)
                            .overlay(
                                Circle()
                                    .stroke(Color.brightRed, lineWidth: 2)
                            )
                        Spacer()
                    }
                    ProgressView()
                }
            }
        } else {
            NavigationLink(destination: destinationView) {
                RedCardView {
                    HStack {
                        Text(title).font(.system(size: 18)).fontWeight(.bold).foregroundColor(.black)
                        Spacer()
                        if !notificationBubbleText.isEmpty {
                            Text(notificationBubbleText)
                                .foregroundColor(.brightRed)
                                .padding(12)
                                .overlay(
                                    Circle()
                                        .stroke(Color.brightRed, lineWidth: 2)
                                )
                            Spacer()
                        }
                        Image(systemName: "arrow.right").foregroundColor(Color.black)
                    }
                }
            }
        }
    }
}

struct ArrowViewButton: View {
    @ObservedObject private var _dm = DataManager.shared

    var title: String
    @Binding var loading: Bool
    let onButtonPress: () -> Void

    init(title: String, loading: Binding<Bool> = Binding(get: { false }, set: { _ in }), onButtonPress: @escaping () -> Void) {
        self.title = title
        self._loading = loading
        self.onButtonPress = onButtonPress
    }

    var body: some View {
        if loading {
            BlackCardView {
                HStack {
                    Text(title).font(.system(size: 18)).fontWeight(.bold).foregroundColor(.black)
                    Spacer()
                    ProgressView()
                }
            }
        } else {
            BlackCardView {
                HStack {
                    Text(title).font(.system(size: 18)).fontWeight(.bold).foregroundColor(.black)
                    Spacer()
                    Image(systemName: "arrow.right").foregroundColor(Color.black)
                }
            }.onTapGesture {
                self.onButtonPress()
            }
        }
    }
}

