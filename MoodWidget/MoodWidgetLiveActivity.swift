//
//  MoodWidgetLiveActivity.swift
//  MoodWidget
//
//  Created by Rosie O'Marrow on 3/31/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MoodWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var mood: Mood
    }
}

struct MoodWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MoodWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("\(context.state.mood.rawValue)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.mood.rawValue)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.mood.rawValue)")
            } minimal: {
                Text(context.state.mood.rawValue)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension MoodWidgetAttributes {
    fileprivate static var preview: MoodWidgetAttributes {
        MoodWidgetAttributes()
    }
}

extension MoodWidgetAttributes.ContentState {
    fileprivate static var mood: MoodWidgetAttributes.ContentState {
        MoodWidgetAttributes.ContentState(mood: .none)
     }
     
     
}

#Preview("Notification", as: .content, using: MoodWidgetAttributes.preview) {
   MoodWidgetLiveActivity()
} contentStates: {
    MoodWidgetAttributes.ContentState.mood

}
