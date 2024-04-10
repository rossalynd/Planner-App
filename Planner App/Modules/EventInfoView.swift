//
//  EventInfoView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/25/24.
//

import SwiftUI
import EventKit

struct EventInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    var event: EKEvent
    var body: some View {
        Text("EventInfoView!")
        Button("Back") {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

