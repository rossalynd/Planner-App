//
//  ThemeController.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/26/24.
//

import Foundation
import SwiftUI
class ThemeController: ObservableObject {
    @Published var backgroundType: BackgroundType = .beige
    
    enum BackgroundType: String, CaseIterable {
        case bluePurpleGradient = "Blue > Purple"
        case beige = "Beige"
        case custom = "Custom"
        
        var id: Self { self }
    }

    func getBackgroundView() -> some View {
        switch self.backgroundType {
        case .bluePurpleGradient:
            return AnyView(
                ZStack {
                    BluePurpleGradientBackground()
                    
                }
            )
        case .beige:
            return AnyView(BeigeBackground())
        case .custom:
            return AnyView(CustomBackground())
            
        }
    }
}

extension View {
    func themedBackground(themeController: ThemeController) -> some View {
        self.background(themeController.getBackgroundView())
    }
}
