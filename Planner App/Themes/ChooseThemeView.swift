//
//  ChooseThemeView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/27/24.
//

import SwiftUI
import PhotosUI

struct ChooseThemeView: View {
    @EnvironmentObject var appModel: AppModel
    @State private var isShowingPicker = false
    @State var photoBackground: PhotosPickerItem?
    @State var backgroundChoice: String = "Default"
    @State var isGradient: Bool = false
    @State var expandAdvanced: Bool = false
    let columnCount: Int = 5
    let gridSpacing: CGFloat = 2
    let backgrounds: [String] = [
        "beigefloralgeometric", "bluefloral", "bluegeode", "celestial", "celestial2",
        "constellation", "geometric", "lightgeometric", "minimalisticcelestial",
        "pinkacademic", "pinkdaisies", "pinkgeode", "pinkleopard", "pinkleopardprint",
        "purpledaisies", "redyellowrose", "stainedglass", "summer", "summer2",
        "summerscene", "tropical"
    ]

    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
                HStack {
                    Text("Background")
                    Spacer()
                    Picker("Background Type", selection: $appModel.backgroundType) {
                        ForEach(AppModel.BackgroundType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                        
                    }
                }.pickerStyle(MenuPickerStyle())
                if appModel.backgroundType == .custom {
                    HStack {
                        Text("Choose Color")
                        ColorPickerView(selectedColor: $appModel.color).onChange(of: appModel.color) { oldValue, newValue in
                            if !isGradient {
                                appModel.secondaryColor = appModel.color
                                appModel.saveSettings()
                                
                            }
                        }
                    }
                    if isGradient {
                        HStack {
                            Text("Choose Gradient Color")
                            ColorPickerView(selectedColor: $appModel.secondaryColor)
                        }
                    }
                    Toggle("Gradient", isOn: $isGradient).onChange(of: isGradient) { oldValue, newValue in
                        if !newValue {
                            // Set secondaryColor to nil if not a gradient
                            appModel.secondaryColor = appModel.color
                            appModel.saveSettings()
                        }
                    }
                }
                
                HStack {
                    Text("Pattern")
                    Spacer()
                    Picker("Background Type", selection: $appModel.overlayType) {
                        ForEach(AppModel.OverlayType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                if appModel.overlayType == .backgroundImage {
                    GeometryReader { geometry in
                        HStack {
                            Spacer()
                            ScrollView(.vertical) {
                                LazyVGrid(columns: Array(repeating: .init(.flexible(minimum: 100, maximum: 300), spacing: gridSpacing), count: columnCount), spacing: gridSpacing) {
                                    ForEach(backgrounds, id: \.self) { background in
                                        
                                        Image(background).resizable(resizingMode: .stretch).border(appModel.backgroundImage == background ? .green : .clear, width: 2).frame(maxWidth: 100, maxHeight: 100).onTapGesture {
                                            appModel.backgroundImage = background
                                            print("Set background image to \(background)")
                                            print("Background image is now \(appModel.backgroundImage)")
                                            appModel.saveSettings()
                                        }
                                    }
                                }
                            }.frame(maxWidth: geometry.size.width / 2, maxHeight: geometry.size.height / 5).scrollIndicators(.hidden)
                            Spacer()
                        }
                    }
                }

                if appModel.overlayType == .photoBackground {
                    
                    
                    PhotosPicker(selection: $photoBackground, matching: .images) {
                        Text("Choose Background Photo")
                    }
                        .onChange(of: photoBackground) { oldItem, newItem in
                            handleSelectedPhoto(newItem)
                            appModel.saveSettings()
                        }
                    

                    
                }
                DisclosureGroup("Advanced Settings", isExpanded: $expandAdvanced) {
                    HStack {
                        Text("Module Corner Radius")
                        Spacer()
                        HorizontalSlider(value: $appModel.moduleCornerRadius, range: 0...50, onEditingChanged: { editing in
                            appModel.saveSettings()
                        }).padding(30)
                    }
                    HStack {
                        Text("")
                    }
                    
                }
            }
            .padding()
        }
    }

    func handleSelectedPhoto(_ item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    let imageName = "CurrentAppBackground"
                    appModel.photoBackgroundImage = UIImage(data: data)
                   
                        let saved = self.saveImageToDocumentsDirectory(imageData: data, imageName: imageName)
                        if saved {
                            print("Image saved successfully")
                            self.appModel.saveSettings()
                        } else {
                            print("Error: Image not saved")
                        }
                    
                }
            } catch {
                print("Error loading photo: \(error)")
            }
        }
    }

    func saveImageToDocumentsDirectory(imageData: Data, imageName: String) -> Bool {
        let fullPath = appModel.getDocumentsDirectory().appendingPathComponent(imageName)
        do {
            try imageData.write(to: fullPath)
            // Save just the imageName to UserDefaults here if needed, but it looks like you do it elsewhere
            print("Saving to path: \(fullPath)")
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }



   

}


#Preview {
    ChooseThemeView()
        .environmentObject(AppModel())

}
