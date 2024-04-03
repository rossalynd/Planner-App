//
//  AppIntent.swift
//  MoodWidget
//
//  Created by Rosie O'Marrow on 3/31/24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")
   
}
