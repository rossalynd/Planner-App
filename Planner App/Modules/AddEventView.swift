//
//  AddEventView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/25/24.
//

import SwiftUI

import SwiftUI

struct AddEventView: View {
    @State private var eventName: String = ""
    @State private var eventDate: Date = Date()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                
            }
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Event Name", text: $eventName)
                    DatePicker("Date", selection: $eventDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Event")
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
            
        }
    }

    var cancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }

    var saveButton: some View {
        Button("Save") {
            // Add logic to save the event
            presentationMode.wrappedValue.dismiss()
        }
    }
}



#Preview {
    AddEventView()
}
