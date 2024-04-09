//
//  CreateEventView.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 4/19/23.
//

import SwiftUI

struct CreateEventView: View {
    @ObservedObject private var _dm = DataManager.shared

    init(events: Binding<[EventModel]>) {
        self._events = events
        self.editingEvent = nil
        self._title = State(initialValue: "")
        self._description = State(initialValue: "")
        self._date = State(initialValue: "")
        self._startTime = State(initialValue: "")
        self._endTime = State(initialValue: "")
    }

    init(events: Binding<[EventModel]>, event: EventModel) {
        self._events = events
        self.editingEvent = event
        self._title = State(initialValue: event.title)
        self._description = State(initialValue: event.description)
        self._date = State(initialValue: event.date)
        self._startTime = State(initialValue: event.startTime)
        self._endTime = State(initialValue: event.endTime)
    }

    private var editingEvent: EventModel?

    @Binding var events: [EventModel]

    @State private var title: String
    @State private var description: String
    @State private var date: String
    @State private var startTime: String
    @State private var endTime: String

    @State private var loading: Bool = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack {
            GeometryReader { gr in
                ScrollView {
                    Text("Create Event")
                        .font(Font.system(size: 36, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.trailing, 0)
                    TextField("", text: $title)
                        .padding(.top, 8)
                        .padding(.trailing, 0)
                        .textFieldStyle(.roundedBorder)
                        .placeholder(when: title.isEmpty) {
                            Text("Title").foregroundColor(.gray).padding().padding(.top, 4)
                        }
                    TextField("", text: $date)
                        .padding(.top, 8)
                        .padding(.trailing, 0)
                        .textFieldStyle(.roundedBorder)
                        .placeholder(when: date.isEmpty) {
                            Text("Date yyyy/MM/dd formatted").foregroundColor(.gray).padding().padding(.top, 4)
                        }
                    TextField("", text: $startTime)
                        .padding(.top, 8)
                        .padding(.trailing, 0)
                        .textFieldStyle(.roundedBorder)
                        .placeholder(when: startTime.isEmpty) {
                            Text("Start Time").foregroundColor(.gray).padding().padding(.top, 4)
                        }
                    TextField("", text: $endTime)
                        .padding(.top, 8)
                        .padding(.trailing, 0)
                        .textFieldStyle(.roundedBorder)
                        .placeholder(when: endTime.isEmpty) {
                            Text("End Time").foregroundColor(.gray).padding().padding(.top, 4)
                        }
                    TextEditor(text: $description)
                        .padding(.top, 8)
                        .padding(.trailing, 0)
                        .textFieldStyle(.roundedBorder)
                        .frame(minHeight: 100)
                        .fixedSize(horizontal: false, vertical: true)
                        .placeholder(when: description.isEmpty) {
                            Text("Description").foregroundColor(.gray).padding().multilineTextAlignment(.center)
                        }
                    LoadingButtonView($loading, width: gr.size.width - 32, buttonText: "Submit") {
                        let valResult = validateFields()
                        if !valResult.hasError {
                            self.loading = true
                            if let editingEvent = editingEvent {
                                // EDIT
                                let edited = EventModel(id: editingEvent.id, title: title, description: description, date: date, startTime: startTime, endTime: endTime, isStarted: editingEvent.isStarted, isFinished: editingEvent.isFinished)



                                AdminService.updateEvent(edited) { updatedEvent in
                                    runOnMainThread {
                                        for (index, event) in self.events.enumerated() {

                                            guard event.id == updatedEvent.id else { continue }
                                            self.events[index] = updatedEvent
                                            break

                                        }
                                        AlertManager.shared.showOkAlert("Event Edited", onOkAction: {
                                            runOnMainThread {
                                                self.loading = false
                                                self.mode.wrappedValue.dismiss()
                                            }
                                        })
                                    }

                                } failureCase: { error in
                                    self.loading = false
                                }

                            } else {
                                // CREATE
                                let event = CreateEventModel(title: title, description: description, date: date, startTime: startTime, endTime: endTime, isStarted: "FALSE", isFinished: "FALSE")

                                AdminService.createEvent(event) { createdEvent in
                                    runOnMainThread {
                                        self.events.insert(createdEvent, at: 0)
                                        AlertManager.shared.showOkAlert("Event Created", onOkAction: {
                                            runOnMainThread {
                                                self.loading = false
                                                self.mode.wrappedValue.dismiss()
                                            }
                                        })
                                    }
                                } failureCase: { error in
                                    self.loading = false
                                }
                            }

                        } else {
                            AlertManager.shared.showOkAlert("Validation Error", message: valResult.getErrorMessages(), onOkAction: nil)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 0)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.lightGray)
    }

    private func validateFields() -> ValidationResult {
        return Validator.validateMultiple([
            ValidationGroup(text: title, validationType: .title),
            ValidationGroup(text: date, validationType: ValidationType.date),
            ValidationGroup(text: startTime, validationType: ValidationType.startTime),
            ValidationGroup(text: endTime, validationType: ValidationType.endTime),
            ValidationGroup(text: description, validationType: .description)
        ])
    }
}
