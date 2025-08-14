//
//  CardView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/11/22.
//

import SwiftUI

struct CardView<Content: View>: ContainerView {

    var content: () -> Content

    var body: some View {
        VStack(content: content)
            .frame(maxWidth: .infinity)
            .padding(16)
            .overlay(
                RoundedRectangle(cornerRadius: 20).strokeBorder(Color.gray, lineWidth: 2)
            )
    }
}

struct CardWithBindingTitleView<Content: View>: ContainerViewWithBindingTitle {

    @Binding var title: String
    var content: () -> Content

    init(title: Binding<String>, content: @escaping () -> Content) {
        self._title = title
        self.content = content
    }

    var body: some View {
        CardView {
            HStack {
                Spacer()
                Text(title)
                    .font(.system(size: 24))
                    .underline(true)
                    .foregroundColor(.darkGray)
                Spacer()
            }
            VStack(content: content)
        }
    }

}

struct CardWithTitleView<Content: View>: ContainerViewWithTitle {

    let title: String
    var content: () -> Content

    init(title: String, content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        CardView {
            HStack {
                Spacer()
                Text(title)
                    .font(.system(size: 24))
                    .frame(alignment: .center)
                    .multilineTextAlignment(.center)
                    .underline(true)
                    .foregroundColor(.darkGray)
                Spacer()
            }
            VStack(content: content)
        }
    }

}

struct BlackCardView<Content: View>: ContainerView {

    var content: () -> Content

    var body: some View {
        VStack(content: content)
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 20).strokeBorder(Color.black, lineWidth: 2)
        )
    }
}

struct BlackCardView2pxPadding<Content: View>: ContainerView {

    var content: () -> Content

    var body: some View {
        VStack(content: content)
        .padding(2)
        .overlay(
            RoundedRectangle(cornerRadius: 20).strokeBorder(Color.black, lineWidth: 2)
        )
    }
}

struct BlackBorder<Content: View>: ContainerView {

    var content: () -> Content

    var body: some View {
        VStack(content: content)
        .overlay(
            Rectangle().strokeBorder(Color.black, lineWidth: 2)
        )
    }
}

struct RedCardView<Content: View>: ContainerView {

    var content: () -> Content

    var body: some View {
        VStack(content: content)
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 20).strokeBorder(Color.brightRed, lineWidth: 2)
        )
    }
}

struct GreenCardView<Content: View>: ContainerView {

    var content: () -> Content

    var body: some View {
        VStack(content: content)
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 20).strokeBorder(Color.darkGreen, lineWidth: 2)
        )
    }
}

struct BlueCardView<Content: View>: ContainerView {

    var content: () -> Content

    var body: some View {
        VStack(content: content)
        .padding(16)
        .overlay(
            RoundedRectangle(cornerRadius: 20).strokeBorder(Color.blue, lineWidth: 2)
        )
    }
}

#Preview {
    CardView {
        EmptyView()
    }
}

protocol ContainerView: View {
    associatedtype Content
    init(content: @escaping () -> Content)
}

extension ContainerView {

    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.init(content: content)
    }

}

protocol ContainerViewWithTitle: View {
    associatedtype Content
    init(title: String, content: @escaping () -> Content)
}

extension ContainerViewWithTitle {

    init(title: String, @ViewBuilder _ content: @escaping () -> Content) {
        self.init(title: title, content: content)
    }

}

protocol ContainerViewWithBindingTitle: View {
    associatedtype Content
    init(title: Binding<String>, content: @escaping () -> Content)
}

extension ContainerViewWithBindingTitle {

    init(title: Binding<String>, @ViewBuilder _ content: @escaping () -> Content) {
        self.init(title: title, content: content)
    }

}
