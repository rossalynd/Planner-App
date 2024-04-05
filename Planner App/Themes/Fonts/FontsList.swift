import SwiftUI

struct FontsList: View {
    @EnvironmentObject var appModel: AppModel
    
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
        
        VStack() {
            HStack{
                Text("Header Font")
                Spacer()
            }
            Text("\(Date().dayOfWeek), \(Date().monthName) \(Date().dateNum), \(Date().year)").font(Font.custom("\(appModel.headerFont)", size: 40)).foregroundStyle(.black)
            
            Picker("Font", selection: $appModel.headerFont) {
                ForEach(fontsList, id: \.self) { font in
                    Text("\(font)").tag(font)
                }
                .onChange(of: appModel.headerFont) {
                    appModel.saveSettings()
                }
                
            }.pickerStyle(.wheel).frame(maxWidth: 200)
        }
    }
    
   
}

#Preview {
    FontsList()
        .environmentObject(AppModel())
}
