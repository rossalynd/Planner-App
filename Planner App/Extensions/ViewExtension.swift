//
//  ViewExtension.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 4/1/24.
//
import SwiftUI
import Foundation
extension View {
    func themedBackground(appModel: AppModel) -> some View {
        self.background(ZStack {
            appModel.getBackgroundView(for: appModel.backgroundType)
            appModel.getOverlayView()
        })
    }
}
