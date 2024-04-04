//
//  ThemeController.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/26/24.
//

import Foundation
import SwiftUI
class ThemeController: ObservableObject {
    @Published var backgroundType: BackgroundType = .bluePurpleGradient
    @Published var overlayType: OverlayType = .none
    
    enum BackgroundType: String, CaseIterable {
        case bluePurpleGradient = "Blue > Purple"
        case beige = "Beige"
        case custom = "Custom"
        
        var id: Self { self }
    }
    enum OverlayType: String, CaseIterable {
        case hearts = "Hearts"
        case stripes = "Stripes"
        case customPattern = "Custom"
        case none = "None"
        
        var id: Self { self }
    }


    func getBackgroundView() -> some View {
        switch self.backgroundType {
        case .bluePurpleGradient:
            return AnyView(BluePurpleGradientBackground())
        case .beige:
            return AnyView(BeigeBackground())
        case .custom:
            return AnyView(CustomBackground())
            
        }
    }
    func getOverlayView() -> some View {
            switch self.overlayType {
            case .hearts:
                return AnyView(Hearts())
            case .stripes:
                return AnyView(Text("Stripes"))
            case .customPattern:
                return AnyView(Text("Custom"))
            case .none:
                return AnyView(Text(""))
            }
        }
}


