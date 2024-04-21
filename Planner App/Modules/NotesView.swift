
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import PencilKit
import SwiftData

extension PKDrawing {
    static func loadFromUserDefaults(for date: Date) -> PKDrawing {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let key = "drawingData-\(dateFormatter.string(from: date))"
        
        guard let data = UserDefaults.standard.data(forKey: key),
              let drawing = try? PKDrawing(data: data) else {
            print("No drawing found for \(date), returning a new instance.")
            return PKDrawing() // Ensure this is a fresh instance
        }
        return drawing
    }
    
    func saveToUserDefaults(for date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let key = "drawingData-\(dateFormatter.string(from: date))"
        
        let data = self.dataRepresentation()
        UserDefaults.standard.set(data, forKey: key)
        print("saved to \(key)")
    }
}

struct CanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Binding var tool: PKTool
    @Binding var isMenuVisible: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.drawingPolicy = .anyInput // Explicitly allow any input
        canvasView.backgroundColor = .clear
        canvasView.delegate = context.coordinator

        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawing = drawing // This should be outside any conditionals to always update
        uiView.tool = tool
    }

       func makeCoordinator() -> Coordinator {
           Coordinator(self)
       }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: CanvasView

        init(_ canvasView: CanvasView) {
            self.parent = canvasView
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            DispatchQueue.main.async {
                self.parent.drawing = canvasView.drawing
            }
        }

        func canvasViewDidBeginDrawing(_ canvasView: PKCanvasView) {
            DispatchQueue.main.async {
                self.parent.isMenuVisible = false
            }
        }
    }

}




struct NotesView: View {
    @EnvironmentObject var appModel: AppModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.undoManager) private var undoManager
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \Note.dateCreated) private var notes: [Note]
    @State private var drawing = PKDrawing()
    @State private var tool: PKTool = PKInkingTool(.monoline, color: .black, width: 0.5) // Default tool
    @State private var penWidth: CGFloat = 0.5
    @State private var eraserWidth: CGFloat = 20
    @State private var showPenMenu = false
    @State private var showEraserMenu = false
    @State private var isMenuVisible = false
    @State private var currentDisplayedDate: Date




    init() {
           _currentDisplayedDate = State(initialValue: AppModel().displayedDate) // Initialize with your default or current date
       }
    
    func findNoteByDate(notes: [Note], targetDate: Date) -> Note? {
        let calendar = Calendar.current
        let filteredNotes = notes.filter { note in
            calendar.isDate(note.dateCreated, inSameDayAs: targetDate)
        }
        return filteredNotes.sorted { $0.dateModified < $1.dateModified }.last
    }

    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CanvasView(drawing: $drawing, tool: $tool, isMenuVisible: $isMenuVisible)
                            .edgesIgnoringSafeArea(.all)
                            .border(Color(hue: 1.0, saturation: 0.01, brightness: 0.546, opacity: 0.553), width: 1)
                            .padding(.horizontal, 2)
                            .onAppear {
                               
                                DispatchQueue.main.async {
                                    if let drawingData = findNoteByDate(notes: notes, targetDate: appModel.displayedDate)?.data {
                                        do {
                                            drawing = try PKDrawing(data: drawingData)
                                        } catch {
                                            print("Failed to convert Data back to PKDrawing: \(error)")
                                            drawing = PKDrawing()  // Use an empty PKDrawing as a fallback
                                        }
                                    } else {
                                        drawing = PKDrawing()  // Use an empty PKDrawing if no note was found
                                    }
                                    currentDisplayedDate = appModel.displayedDate
                                }
                            }
                            .onChange(of: appModel.displayedDate) { oldDate, newDate in
                                DispatchQueue.main.async {
                                    let drawingData = drawing.dataRepresentation()
                                    modelContext.insert(Note(data: drawingData, dateCreated: oldDate, dateModified: Date(), tags: ["SpaceView"]))
                                    print("Saved drawing to \(oldDate) with data size: \(drawingData.count) bytes")
                                    currentDisplayedDate = newDate
                                    print("currentDisplayedDate changed to \(newDate) from \(oldDate)")

                                    if let drawingData = findNoteByDate(notes: notes, targetDate: currentDisplayedDate)?.data {
                                        do {
                                            drawing = try PKDrawing(data: drawingData)
                                            print("Loaded drawing for \(currentDisplayedDate)")
                                        } catch {
                                            print("Failed to convert Data back to PKDrawing: \(error)")
                                            drawing = PKDrawing()  // Use an empty PKDrawing as a fallback
                                        }
                                    } else {
                                        print("No drawing data found for \(currentDisplayedDate)")
                                        drawing = PKDrawing()  // Use an empty PKDrawing if no note was found
                                    }
                                }
                            }

                    .onChange(of: scenePhase) { oldPhase, newPhase in
                                    switch newPhase {
                                    case .background:
                                        print("App is in background")
                                        let drawingData = drawing.dataRepresentation()
                                        modelContext.insert(Note(data: drawingData, dateCreated: currentDisplayedDate, dateModified: Date(), tags: ["SpaceView"]))
                                    case .inactive:
                                        print("App has become inactive")
                                        let drawingData = drawing.dataRepresentation()
                                        modelContext.insert(Note(data: drawingData, dateCreated: currentDisplayedDate, dateModified: Date(), tags: ["SpaceView"]))
                                    case .active:
                                        print("App is active")
                                    default:
                                        break
                                    }
                                }
                    

                VStack {
                    Spacer()
                    // Pencil Slider
                    if showPenMenu {
                        VStack {
                            HorizontalSlider(
                                value: $penWidth,
                                range: 0.1...5,
                                onEditingChanged: { editing in
                                    showPenMenu = editing
                                }
                            )
                        }
                        .transition(.slide)
                        .animation(.easeOut, value: showPenMenu)
                        .onDisappear {
                            if tool is PKInkingTool {
                                self.tool = PKInkingTool(.monoline, color: .black, width: penWidth)
                            }
                        }
                    }
                    //End Pencil Slider
                    // Eraser Slider
                    if showEraserMenu {
                        VStack {
                            HorizontalSlider(
                                value: $eraserWidth,
                                range: 1...50,
                                onEditingChanged: { editing in
                                    showEraserMenu = editing
                                }
                            )
                        }
                        .onDisappear {
                            // Update the eraser tool with the new width when the menu is closed
                            if tool is PKEraserTool {
                                self.tool = PKEraserTool(.bitmap, width: eraserWidth * 10)
                            }
                        }
                    }
                    //End Eraser Slider
                    HStack {
                        HStack {
                            Button( action: {undoManager?.undo()} ) {
                                Image(systemName: "arrow.uturn.backward.circle.fill")
                                
                            }.foregroundColor(Color.black).font(.title).background(.white).clipShape(Circle()).shadow(radius: 2, x: 3, y: 3)
                            
                            
                            Button(action: {undoManager?.redo()} ) {
                                Image(systemName: "arrow.uturn.forward.circle.fill")
                                
                            }.foregroundColor(Color.black).font(.title).background(.white).clipShape(Circle()).shadow(radius: 2, x: 3, y: 3)
                            
                        }
                                            
                        
                            // Pencil Button
                            Button(action: {
                                if tool is PKInkingTool {
                                    showPenMenu.toggle() // Toggle pen menu visibility
                                } else {
                                    // Switch to pen and show its menu
                                    showEraserMenu = false
                                    self.tool = PKInkingTool(.monoline, color: .black, width: penWidth)
                                }
                            }) {
                                Image(systemName: "pencil.circle.fill").foregroundColor(Color.black).font(.title).background(.white).clipShape(Circle()).shadow(radius: 2, x: 3, y: 3)
                            }
                            //End Pencil Button
                        //Between two Buttons
                        //Eraser Button
                            Button(action: {
                                if tool is PKEraserTool {
                                    showEraserMenu.toggle() // Toggle eraser menu visibility
                                } else {
                                    // Switch to eraser and show its menu
                                    showPenMenu = false
                                    self.tool = PKEraserTool(.bitmap, width: eraserWidth)
                                    
                                }
                            }) {
                                Image(systemName: "eraser.fill").foregroundColor(Color.black).font(.title).background(.white).clipShape(Circle()).shadow(radius: 2, x: 3, y: 3)
                            }
                            
                        }.padding(.horizontal)
                }.padding(.bottom, 10)
            }
        }
        
    }
}






