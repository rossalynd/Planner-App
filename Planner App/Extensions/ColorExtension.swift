//
//  ColorExtension.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/27/24.
//

import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
typealias PlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
typealias PlatformColor = NSColor
#endif

extension Color {
    

        static func from(uiColor: UIColor?) -> Color {
            guard let uiColor = uiColor else { return Color.black } // Default color if nil
            return Color(uiColor)
        }
    


        
    
    
    func toHex(alpha: Bool = false) -> String? {
        // Convert Color to PlatformColor (UIColor or NSColor)
        #if canImport(UIKit)
        let platformColor = UIColor(self)
        #elseif canImport(AppKit)
        let platformColor = NSColor(self)
        #endif
        
        // Extract RGBA components
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alphaValue: CGFloat = 0
        platformColor.getRed(&red, green: &green, blue: &blue, alpha: &alphaValue)
        
        // Format RGBA components into a hex string
        if alpha {
            return String(format: "#%02lX%02lX%02lX%02lX",
                          lroundf(Float(red * 255)),
                          lroundf(Float(green * 255)),
                          lroundf(Float(blue * 255)),
                          lroundf(Float(alphaValue * 255)))
        } else {
            return String(format: "#%02lX%02lX%02lX",
                          lroundf(Float(red * 255)),
                          lroundf(Float(green * 255)),
                          lroundf(Float(blue * 255)))
        }
    }

    static func fromHex(_ hex: String) -> Color? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red, green, blue, alpha: Double
        if hexSanitized.count == 8 {
            red = Double((rgb & 0xff000000) >> 24) / 255.0
            green = Double((rgb & 0x00ff0000) >> 16) / 255.0
            blue = Double((rgb & 0x0000ff00) >> 8) / 255.0
            alpha = Double(rgb & 0x000000ff) / 255.0
            return Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
        } else if hexSanitized.count == 6 {
            red = Double((rgb & 0xff0000) >> 16) / 255.0
            green = Double((rgb & 0x00ff00) >> 8) / 255.0
            blue = Double(rgb & 0x0000ff) / 255.0
            return Color(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
        } else {
            print("Invalid hex string")
            // Invalid hex string
            return nil
        }
    }
}
