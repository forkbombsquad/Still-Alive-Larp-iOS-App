//
//  ContentView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 10/17/22.
//

import SwiftUI

struct MainView: View {
    @ObservedObject private var _dm = DataManager.shared

    @State private var username: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = true
    @State private var navigateToCreateAccount = false

    @State var loading = false

    @State var player: PlayerModel?
    @State var character: FullCharacterModel?

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    NavigationLink(destination: HomeTabBarView(), tag: 1, selection: DataManager.$shared.actionState) {
                        EmptyView()
                    }
                    Image("StillAliveLogo_Black")
                        .resizable()
                        .foregroundColor(.accentColor)
                        .aspectRatio(contentMode: .fit)
                        .padding(.top, 32)
                    TextField("Username", text: $username)
                        .padding(.top, 32)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                    PasswordField(hintText: "Password", password: $password)

                    GeometryReader { gr in
                        VStack {
                            HStack {
                                Toggle(isOn: $rememberMe, label: {})
                                    .labelsHidden()
                                    .tint(.brightRed)
                                    .onTapGesture {
                                        rememberMe.toggle()
                                    }
                                Text("Remember Me")
                                Spacer()

                                LoadingButtonView($loading, width: gr.size.width * 0.35, height: 60, buttonText: "Log In", progressViewOffset: 0) {
                                    self.loading = true

                                    VersionService.getVersions { versions in
                                        let currentVersion = getBuildNumber()
                                        if (currentVersion < versions.iosVersion) {
                                            self.loading = false
                                            AlertManager.shared.showCustomOrCancelAlert(
                                                "Update Required!",
                                                message: "Your version of the Still Alive Larp App is outdated. Please visit the App Store to update in order to use online features! \n\nCurrent Build Number: \(currentVersion)\nTarget Build Number: \(versions.iosVersion)",
                                                customButtonText: "Open App Store", onCustomButtonPress: {
                                                    if let appStoreURL = URL(string: "https://apps.apple.com/us/app/still-alive-larp/id6449710836") {
                                                     UIApplication.shared.open(appStoreURL)
                                                    }
                                                })
                                        } else {
                                            UserAndPassManager.shared.setUAndP(username, p: password, remember: rememberMe)
                                            PlayerService.signInPlayer { player in
                                                runOnMainThread {
                                                    self.loading = false
                                                    DataManager.shared.actionState = 1
                                                    PlayerManager.shared.setPlayer(player)
                                                }


                                            } failureCase: { _ in
                                                self.loading = false
                                            }
                                        }
                                    } failureCase: { error in
                                        self.loading = false
                                    }
                                }
                            }.padding(.top, 32)
                            NavigationLink(destination: CreateAccountView()) {
                                Text("Create Account")
                                    .frame(width: gr.size.width, height: 90)
                                    .background(Color.midRed)
                                    .cornerRadius(15)
                                    .foregroundColor(.white)
                                    .tint(.midRed)
                                    .controlSize(.large)
                            }.navigationViewStyle(.stack)

                            NavigationLink(destination: ContactView()) {
                                Text("Contact Us")
                                    .frame(width: gr.size.width, height: 90)
                                    .background(Color.midRed)
                                    .cornerRadius(15)
                                    .foregroundColor(.white)
                                    .tint(.midRed)
                                    .controlSize(.large)
                            }

                            if player != nil {
                                NavigationLink(destination: OfflineAccountView()) {
                                    Text("Offline Mode")
                                        .frame(width: gr.size.width, height: 90)
                                        .background(Color.midRed)
                                        .cornerRadius(15)
                                        .foregroundColor(.white)
                                        .tint(.midRed)
                                        .controlSize(.large)
                                }
                            }
                        }

                    }

                }
            }
            .padding(16)
            .background(Color.lightGray)
            .onAppear {
                self.username = getPrefilledUser()
                self.password = getPrefilledPass()
                self.player = LocalDataHandler.shared.getPlayer()
                self.character = LocalDataHandler.shared.getCharacter()
            }
        }
    }

    private func getPrefilledUser() -> String {
        var u = UserAndPassManager.shared.getTempU()
        if u == nil && UserAndPassManager.shared.remember() {
            u = UserAndPassManager.shared.getU()
        }
        return u ?? ""
    }

    private func getPrefilledPass() -> String {
        var p = UserAndPassManager.shared.getTempP()
        if p == nil && UserAndPassManager.shared.remember() {
            p = UserAndPassManager.shared.getP()
        }
        return p ?? ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
