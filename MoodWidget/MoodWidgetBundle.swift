//
//  MoodWidgetBundle.swift
//  MoodWidget
//
//  Created by Rosie O'Marrow on 3/31/24.
//

import WidgetKit
import SwiftUI

@main
struct MoodWidgetBundle: WidgetBundle {
    var body: some Widget {
        MoodWidget()
        MoodWidgetLiveActivity()
    }
}
