//
//  CustomColor.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/27/24.
//

import Foundation
import SwiftUI

class CustomColor: ObservableObject {
    @Published var color: Color = Color(.blue)
    @Published var secondaryColor: Color = (.blue)
    @Published var patternColor: Color = (.white)
    @Published var moduleColor: Color = Color("DefaultWhite")
}
