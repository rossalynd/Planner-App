//
//  ImageColors.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 4/5/24.
//

import Foundation
import SwiftUI
import UIKit

struct ImageColors {
    var dominant: UIColor?
    var darkest: UIColor?
    var lightest: UIColor?
}




struct RGBA32: Equatable, Hashable {
    var color: UInt32
    
    var red: UInt8 {
        return UInt8((color >> 24) & 0xFF)
    }
    
    var green: UInt8 {
        return UInt8((color >> 16) & 0xFF)
    }
    
    var blue: UInt8 {
        return UInt8((color >> 8) & 0xFF)
    }
    
    var alpha: UInt8 {
        return UInt8(color & 0xFF)
    }
    
    func toUIColor() -> UIColor {
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha) / 255.0)
    }
    
    static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
}

func analyzeImageColors(uiImage: UIImage) -> ImageColors {
    guard let inputCGImage = uiImage.cgImage else { return ImageColors() }
    let width = inputCGImage.width
    let height = inputCGImage.height
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bytesPerPixel = 4
    let bitsPerComponent = 8
    let bytesPerRow = bytesPerPixel * width
    let bitmapInfo = RGBA32.bitmapInfo

    guard let context = CGContext(data: nil, width: width, height: height,
                                  bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace,
                                  bitmapInfo: bitmapInfo) else { return ImageColors() }
    context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    guard let buffer = context.data else { return ImageColors() }
    
    let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
    var imageColors: [RGBA32: Int] = [:]

    for row in 0 ..< height {
        for column in 0 ..< width {
            let offset = row * width + column
            let color = pixelBuffer[offset]
            // Only count fully opaque colors
            if color.alpha == 255 {
                imageColors[color, default: 0] += 1
            }
        }
    }

    if let mostCommonColor = imageColors.max(by: { $0.value < $1.value })?.key.toUIColor() {
        print("Dominant color is \(mostCommonColor)")
    }

    return ImageColors(
        dominant: imageColors.max(by: { $0.value < $1.value })?.key.toUIColor(),
        darkest: imageColors.min(by: { $0.key.brightnessIgnoringAlpha < $1.key.brightnessIgnoringAlpha })?.key.toUIColor(),
        lightest: imageColors.max(by: { $0.key.brightnessIgnoringAlpha < $1.key.brightnessIgnoringAlpha })?.key.toUIColor()
    )
}

extension RGBA32 {
    var brightnessIgnoringAlpha: CGFloat {
        return CGFloat(red) * 0.299 + CGFloat(green) * 0.587 + CGFloat(blue) * 0.114
    }
}




