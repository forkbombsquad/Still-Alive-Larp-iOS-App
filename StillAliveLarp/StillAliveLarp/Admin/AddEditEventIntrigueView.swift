//
//  AddEditEventIntrigueView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/26/23.
//

import SwiftUI

struct AddEditEventIntrigueView: View {
    @ObservedObject var _dm = DataManager.shared

    let event: EventModel
    @State var loadingIntrigue: Bool = true
    @State var loadingSubmit: Bool = false

    @State var investigatorMessage = ""
    @State var interrogatorMessage = ""

    @State var intrigue: IntrigueModel? = nil

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    Text(getTitleText())
                        .font(Font.system(size: 36, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.trailing, 0)
                    if !loadingIntrigue {
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

                        LoadingButtonView($loadingSubmit, width: gr.size.width - 32, buttonText: "Submit") {
                            let valResult = validateFields()
                            if !valResult.hasError {
                                self.loadingSubmit = true
                                if var editIntrigue = self.intrigue {
                                    editIntrigue.interrogatorMessage = self.interrogatorMessage
                                    editIntrigue.investigatorMessage = self.investigatorMessage
                                    editIntrigue.webOfInformantsMessage = ""

                                    AdminService.updateIntrigue(editIntrigue) { _ in
                                        runOnMainThread {
                                            AlertManager.shared.showOkAlert("Intrigue Updated") {
                                                runOnMainThread {
                                                    self.loadingSubmit = false
                                                    self.mode.wrappedValue.dismiss()
                                                }
                                            }
                                        }
                                    } failureCase: { error in
                                        self.loadingSubmit = false
                                    }
                                } else {
                                    let intrigue = IntrigueCreateModel(eventId: event.id, investigatorMessage: investigatorMessage, interrogatorMessage: interrogatorMessage, webOfInformantsMessage: "")
                                    AdminService.createIntrigue(intrigue) { intrigue in
                                        runOnMainThread {
                                            AlertManager.shared.showOkAlert("Intrigue Created") {
                                                runOnMainThread {
                                                    self.loadingSubmit = false
                                                    self.mode.wrappedValue.dismiss()
                                                }
                                            }
                                        }
                                    } failureCase: { error in
                                        self.loadingSubmit = false
                                    }

                                }

                            } else {
                                AlertManager.shared.showOkAlert("Validation Error", message: valResult.getErrorMessages(), onOkAction: {})
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
            self.investigatorMessage = intrigue?.investigatorMessage ?? ""
            self.interrogatorMessage = intrigue?.interrogatorMessage ?? ""
            IntrigueService.getIntrigue(event.id, onSuccess: { intrigue in
                self.intrigue = intrigue
                self.investigatorMessage = intrigue.investigatorMessage
                self.interrogatorMessage = intrigue.interrogatorMessage
                self.loadingIntrigue = false
            }, failureCase: { _ in
                self.loadingIntrigue = false
            })
        }
    }

    private func validateFields() -> ValidationResult {
        return Validator.validateMultiple([
            ValidationGroup(text: investigatorMessage, validationType: .intrigue),
            ValidationGroup(text: interrogatorMessage, validationType: .intrigue)
        ])
    }

    func getTitleText() -> String {
        guard !loadingIntrigue else { return "Loading..." }
        return intrigue == nil ? "Create Intrigue" : "Edit Intrigue"
    }

}

#Preview {
    let dm = DataManager.shared
    dm.debugMode = true
    dm.loadMockData()
    let md = getMockData()
    return AddEditEventIntrigueView(_dm: dm, event: md.event(), intrigue: md.intrigue())
}
