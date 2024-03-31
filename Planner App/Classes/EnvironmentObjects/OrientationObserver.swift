//
//  OrientationObserver.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/30/24.
//

import Foundation
import SwiftUI
import Combine

class OrientationObserver: ObservableObject {
    @Published var isLandscape: Bool = false
    
    init() {
        self.isLandscape = isLandscapeOrientation
        
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.isLandscape = self?.isLandscapeOrientation ?? false
        }
    }
    
    private var isLandscapeOrientation: Bool {
        // Attempt to get a reference to the current UIWindowScene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return false
        }
        return windowScene.interfaceOrientation.isLandscape
    }
}
