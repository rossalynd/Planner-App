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
                    Text("Background Type")
                    Spacer()
                    Picker("Background Type", selection: $appModel.overlayType) {
                        ForEach(AppModel.OverlayType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                if appModel.overlayType == .color {
                HStack {
                    Text("Background Color")
                    Spacer()
                    Picker("Background Color", selection: $appModel.backgroundType) {
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
                
            }
                if appModel.overlayType == .backgroundImage {
                    ScrollView(.vertical) {
                        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: gridSpacing), count: columnCount), spacing: gridSpacing) {
                            ForEach(backgrounds, id: \.self) { background in
                                Image(background).resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipped()
                                    .border(appModel.backgroundImage == background ? Color.green : Color.clear, width: 2)
                                    .onTapGesture {
                                        appModel.backgroundImage = background
                                        appModel.saveSettings()
                                    }
                            }
                        }
                    }.frame(height: 200) // Adjust this height as necessary
                   



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
                
                
                HStack {
                    FontsList()
                    
                }
                HStack {
                    Text("Header Color")
                    Spacer()
                    ColorPickerView(selectedColor: $appModel.headerColor)
                        .onChange(of: appModel.headerColor) {
                            appModel.saveSettings()
                        }
                }
                HStack {
                    Text("Header Capitalization")
                    Spacer()
                    Picker("Header Capitalization", selection: $appModel.headerCase) {
                        ForEach(AppModel.HeaderCapitalization.allCases, id: \.self) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onChange(of: appModel.headerCase) {
                                appModel.saveSettings()
                            }
                }
                DisclosureGroup("Advanced Settings", isExpanded: $expandAdvanced) {
                    HStack {
                        Text("Corner Roundness")
                        Spacer()
                        Slider(value: $appModel.moduleCornerRadius,
                               in: 0...50,
                               step: 1,
                        minimumValueLabel: Text("0"),
                        maximumValueLabel: Text("50"),
                               label: {
                            Text("Section Spacing")
                        })
                    }
                    HStack {
                        Text("Section Spacing")
                        Spacer()
                        Slider(value: $appModel.moduleSpacing,
                               in: 0...30,
                               step: 1,
                        minimumValueLabel: Text("0"),
                        maximumValueLabel: Text("30"),
                               label: {
                            Text("Section Spacing")
                        })
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
   ContentView()
        .environmentObject(AppModel())
        .environmentObject(TasksUpdateNotifier())
        .modelContainer(for: MoodEntry.self)
}
