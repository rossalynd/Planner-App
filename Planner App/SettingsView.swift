//
//  SettingsView.swift
//  Planner App
//
//  Created by Rosie O'Marrow on 3/27/24.
//
import Foundation
import SwiftUI
import PhotosUI

struct SettingsView: View {
    
    @EnvironmentObject var appModel: AppModel
    @State private var isShowingPicker = false
    @State var expandAdvanced: Bool = false
    @State var isGradient: Bool = false
    @State private var image: Image? = nil
    
    
    @State var startOfWeek: WeekStartDay = .monday
    @State var overlayType: AppModel.OverlayType = .color
    @State var backgroundType: AppModel.BackgroundType = .bluePurpleGradient
    @State var photoBackground: PhotosPickerItem?
    @State var backgroundChoice: String = "Default"
    @State var moduleSpacing: Double = 20
    @State var moduleCornerRadius: CGFloat = 20
    @State var headerCase: AppModel.HeaderCapitalization = .capitalized
    @State var headerFont: String = "Default"
    @State var headerColor: Color = .black
    @State var color: Color = .white
    @State var secondaryColor: Color = .gray
    
    
    
    init(appModel: AppModel) {
        _startOfWeek = State(initialValue: appModel.startOfWeek)
        _overlayType = State(initialValue: appModel.overlayType)
        _backgroundType = State(initialValue: appModel.backgroundType)
        if appModel.photoBackgroundImage != nil {
            _image = State(initialValue: Image(uiImage: appModel.photoBackgroundImage!))
        }
        _backgroundChoice = State(initialValue: appModel.backgroundImage)
        _moduleSpacing = State(initialValue: appModel.moduleSpacing)
        _moduleCornerRadius = State(initialValue: appModel.moduleCornerRadius)
        _headerCase = State(initialValue: appModel.headerCase)
        _headerFont = State(initialValue: appModel.headerFont)
        _headerColor = State(initialValue: appModel.headerColor)
        _color = State(initialValue: appModel.color)
        _secondaryColor = State(initialValue: appModel.secondaryColor)
    }

    
    let columnCount: Int = 5
    let gridSpacing: CGFloat = 2
    let backgrounds: [String] = [
        "beigefloralgeometric", "bluefloral", "bluegeode", "celestial", "celestial2",
        "constellation", "geometric", "lightgeometric", "minimalisticcelestial",
        "pinkacademic", "pinkdaisies", "pinkgeode", "pinkleopard", "pinkleopardprint",
        "purpledaisies", "redyellowrose", "stainedglass", "summer", "summer2",
        "summerscene", "tropical"
    ]
    
    let fontsList =
    ["Ariana Violeta",
     "Babylove",
     "Barely Enough",
     "Buster Down",
     "Buycat",
     "Cambridge",
     "Catways",
     "Cheflat",
     "Chintzy",
     "Chronica",
     "Cracker Banana",
     "Cute Aurora",
     "Daveau",
     "Duckname",
     "Farmshow",
     "Freshman",
     "Great Vibes",
     "Lofty Goals",
     "Lowball Neue",
     "Mathelica",
     "Milk Mango",
     "Mocaroni",
     "Morning Breeze",
     "Pacifico",
     "Pacify Angry",
     "Parklane",
     "Party Confetti",
     "Pixeloid Sans",
     "Pixgamer",
     "Playfair Display",
     "Robusta Show",
     "Sacramento",
     "Sandana",
     "Sansilk",
     "Shabina",
     "Sparky Stones",
     "Sunny Spells",
     "Super Carbon",
     "Super Dream",
     "Take Coffee",
     "Wiggly Curves"
    ]
    var body: some View {
        GeometryReader { geometry in
            
            ZStack(alignment: .center) {
                
                ZStack {
                    getBackgroundView(for: appModel.backgroundType).frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height).ignoresSafeArea()
                    appModel.getOverlayView().frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height).ignoresSafeArea()
                }
                
                VStack {
                    Text(headerCase.apply(to: "Settings"))
                        .font(Font.custom("\(headerFont)", size: 40)).foregroundColor(headerColor)
                    HStack {
                        Spacer()
                        Button("Save", action: {
                            saveCustomizationSettings()
                        })
                    }
                    Picker("Start of Week", selection: $startOfWeek) {
                        Text("Sunday").tag(WeekStartDay.sunday)
                        Text("Monday").tag(WeekStartDay.monday)
                    }
                    
                    HStack {
                        Text("Background Type")
                        Spacer()
                        Picker("Background Type", selection: $overlayType) {
                            ForEach(AppModel.OverlayType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                    }
                    if overlayType == .color {
                        HStack {
                            Text("Background Color")
                            Spacer()
                            Picker("Background Color", selection: $backgroundType) {
                                ForEach(AppModel.BackgroundType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                                
                            }
                        }.pickerStyle(MenuPickerStyle())
                        if backgroundType == .custom {
                            HStack {
                                Text("Choose Color")
                                ColorPickerView(selectedColor: $color).onChange(of: color) { oldValue, newValue in
                                    if !isGradient {
                                        secondaryColor = color
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
                                    secondaryColor = color
                                    
                                }
                            }
                        }
                        
                    }
                    if overlayType == .backgroundImage {
                        ScrollView(.vertical) {
                            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: gridSpacing), count: columnCount), spacing: gridSpacing) {
                                ForEach(backgrounds, id: \.self) { background in
                                    Image(background).resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .border(backgroundChoice == background ? Color.green : Color.clear, width: 2)
                                        .onTapGesture {
                                            backgroundChoice = background
                                            
                                        }
                                }
                            }
                        }.frame(height: 200) // Adjust this height as necessary
                        
                        
                        
                        
                    }
                    
                    
                    if overlayType == .photoBackground {
                        
                        
                        PhotosPicker(selection: $photoBackground, matching: .images) {
                            Text("Choose Background Photo")
                        }
                        .onChange(of: photoBackground) { oldItem, newItem in
                            guard let newItem = newItem else { return }
                            Task {
                                await loadImage(from: newItem)
                            }
                            handleSelectedPhoto(newItem)
                        }
                        
                        
                        
                    }
                    
                    
                    HStack{
                        Text("Header Font")
                        Spacer()
                        
                        
                        Picker("Header Font", selection: $headerFont) {
                            ForEach(fontsList, id: \.self) { font in
                                Text("\(font)").tag(font)
                            }
                            
                            
                        }.pickerStyle(.menu).frame(maxWidth: 200)
                    }
                    
                    
                    HStack {
                        Text("Header Color")
                        Spacer()
                        ColorPickerView(selectedColor: $headerColor)
                        
                    }
                    HStack {
                        Text("Header Capitalization")
                        Spacer()
                        Picker("Header Capitalization", selection: $headerCase) {
                            ForEach(AppModel.HeaderCapitalization.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                    }
                    DisclosureGroup("Advanced Settings", isExpanded: $expandAdvanced) {
                        HStack {
                            Text("Corner Roundness")
                            Spacer()
                            Slider(value: $moduleCornerRadius,
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
                            Slider(value: $moduleSpacing,
                                   in: 0...30,
                                   step: 1,
                                   minimumValueLabel: Text("0"),
                                   maximumValueLabel: Text("30"),
                                   label: {
                                Text("Section Spacing")
                            })
                        }
                        
                    }
                    
                    
                    
                    
                    
                    
                    Spacer()
                    
                    
                    
                    
                    
                }.padding(20).background(Color("DefaultWhite")).clipShape(RoundedRectangle(cornerRadius: moduleCornerRadius)).padding(50).frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }.onDisappear() {
                appModel.saveSettings()
                print("Saving settings")
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
    }
    func saveCustomizationSettings() {
        appModel.startOfWeek = startOfWeek
        appModel.overlayType = overlayType
        appModel.backgroundType = backgroundType
        appModel.backgroundImage = backgroundChoice
        handleSelectedPhoto(photoBackground)
        appModel.moduleCornerRadius = moduleCornerRadius
        appModel.moduleSpacing = moduleSpacing
        appModel.headerCase = headerCase
        appModel.headerFont = headerFont
        appModel.headerColor = headerColor
        appModel.color = color
        appModel.secondaryColor = secondaryColor
        appModel.saveSettings()
    }
    func getBackgroundView(for backgroundType: AppModel.BackgroundType) -> some View {
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
            switch overlayType {
            case .color:
                return AnyView(getBackgroundView(for: backgroundType))
            case .hearts:
                return AnyView(Hearts())
            case .backgroundImage:
                if backgroundChoice != "Default" {
                    return AnyView(SeamlessPattern(image: backgroundChoice))
                } else {
                    print("Unable to load Image")
                    return AnyView(Image(systemName: "questionmark"))
                }
                
            case .photoBackground:
                if photoBackground != nil {
                    return AnyView(image)
                } else {
                    print("Unable to load Image")
                    return AnyView(Image(systemName: "questionmark"))
                }
               
            case .none:
                return AnyView(Text(""))
                
            }
        }
    
    
    
    func loadImage(from item: PhotosPickerItem) async {
            // Use the item to load a UIImage
            let photoData = try? await item.loadTransferable(type: Data.self)
            if let photoData = photoData, let uiImage = UIImage(data: photoData) {
                // Convert UIImage to Image for SwiftUI
                image = Image(uiImage: uiImage)
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
    
    func loadImageFromDocumentsDirectory() -> Image? {
        guard let imagePath = UserDefaults.standard.string(forKey: "photoImagePath"),
              let uiImage = UIImage(contentsOfFile: imagePath) else { return nil }
        return Image(uiImage: uiImage)
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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
    SettingsView(appModel: AppModel())
        .environmentObject(AppModel())

}

