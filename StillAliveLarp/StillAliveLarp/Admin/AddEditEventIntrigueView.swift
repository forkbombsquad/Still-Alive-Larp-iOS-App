//
//  AddEditEventIntrigueView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/26/23.
//

import SwiftUI

struct AddEditEventIntrigueView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var DM: DataManager

    let event: FullEventModel
    @State var loading: Bool = true

    @State var investigatorMessage = ""
    @State var interrogatorMessage = ""

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    globalCreateTitleView(getTitleText(), DM: DM)
                    if !loading {
                        TextEditor(text: $investigatorMessage)
                            .padding(.top, 8)
                            .padding(.trailing, 0)
                            .textFieldStyle(.roundedBorder)
                            .frame(minHeight: 100)
                            .fixedSize(horizontal: false, vertical: true)
                            .placeholder(when: investigatorMessage.isEmpty) {
                                Text("Investigator - Fact 1").foregroundColor(.gray).padding().multilineTextAlignment(.center)
                            }
                        TextEditor(text: $interrogatorMessage)
                            .padding(.top, 8)
                            .padding(.trailing, 0)
                            .textFieldStyle(.roundedBorder)
                            .frame(minHeight: 100)
                            .fixedSize(horizontal: false, vertical: true)
                            .placeholder(when: interrogatorMessage.isEmpty) {
                                Text("Interrogator - Fact 2").foregroundColor(.gray).padding().multilineTextAlignment(.center)
                            }

                        LoadingButtonView($loading, width: gr.size.width - 32, buttonText: "Submit") {
                            let valResult = validateFields()
                            if !valResult.hasError {
                                runOnMainThread {
                                    self.loading = true
                                    if var editIntrigue = self.event.intrigue {
                                        editIntrigue.interrogatorMessage = self.interrogatorMessage
                                        editIntrigue.investigatorMessage = self.investigatorMessage
                                        editIntrigue.webOfInformantsMessage = ""

                                        AdminService.updateIntrigue(editIntrigue) { _ in
                                            runOnMainThread {
                                                DM.load()
                                                alertManager.showOkAlert("Intrigue Updated!") {
                                                    runOnMainThread {
                                                        self.loading = false
                                                        self.mode.wrappedValue.dismiss()
                                                    }
                                                }
                                            }
                                        } failureCase: { error in
                                            self.loading = false
                                        }
                                    } else {
                                        let intrigue = IntrigueCreateModel(eventId: event.id, investigatorMessage: investigatorMessage, interrogatorMessage: interrogatorMessage, webOfInformantsMessage: "")
                                        AdminService.createIntrigue(intrigue) { intrigue in
                                            runOnMainThread {
                                                DM.load()
                                                alertManager.showOkAlert("Intrigue Created") {
                                                    runOnMainThread {
                                                        self.loading = false
                                                        self.mode.wrappedValue.dismiss()
                                                    }
                                                }
                                            }
                                        } failureCase: { error in
                                            self.loading = false
                                        }

                                    }
                                }
                            } else {
                                runOnMainThread {
                                    alertManager.showOkAlert("Validation Error", message: valResult.getErrorMessages(), onOkAction: {})
                                }
                            }
                        }
                        .padding(.top, 16)
                        .padding(.trailing, 0)
                    } else {
                        LoadingBlock()
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.lightGray)
        .onAppear {
            self.investigatorMessage = event.intrigue?.investigatorMessage ?? ""
            self.interrogatorMessage = event.intrigue?.interrogatorMessage ?? ""
        }
    }

    private func validateFields() -> ValidationResult {
        return Validator.validateMultiple([
            ValidationGroup(text: investigatorMessage, validationType: .intrigue),
            ValidationGroup(text: interrogatorMessage, validationType: .intrigue)
        ])
    }

    func getTitleText() -> String {
        return event.intrigue == nil ? "Create Intrigue" : "Edit Intrigue"
    }

}

//#Preview {
//    DataManager.shared.setDebugMode(true)
//    let md = getMockData()
//    return AddEditEventIntrigueView(event: md.event(), intrigue: md.intrigue())
//}
