
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import PencilKit

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
    @State private var drawing = PKDrawing()
    @State private var tool: PKTool = PKInkingTool(.monoline, color: .black, width: 0.5) // Default tool
    @State private var penWidth: CGFloat = 0.5
    @State private var eraserWidth: CGFloat = 20
    @State private var showPenMenu = false
    @State private var showEraserMenu = false
    @State private var isMenuVisible = false
    @State private var currentDisplayedDate: Date
    @State private var undoStack: [PKDrawing] = []
    @State private var redoStack: [PKDrawing] = []



    init() {
           _currentDisplayedDate = State(initialValue: AppModel().displayedDate) // Initialize with your default or current date
       }
    
    private func captureForUndo() {
            undoStack.append(drawing)
 
        }

    private func undo() {
        guard !undoStack.isEmpty else { return }
        var lastState = undoStack.removeLast()
        if !undoStack.isEmpty{
            lastState = undoStack.removeLast()
            redoStack.append(drawing) // Move current drawing to redo stack before undoing
            drawing = lastState
        }
    }

    private func redo() {
        guard !redoStack.isEmpty else { return }
        let nextState = redoStack.removeLast()
        undoStack.append(drawing) // Move current drawing to undo stack before redoing

        drawing = nextState
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CanvasView(drawing: $drawing, tool: $tool, isMenuVisible: $isMenuVisible)
                    .edgesIgnoringSafeArea(.all)
                    .border(Color(hue: 1.0, saturation: 0.01, brightness: 0.546, opacity: 0.553), width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    .onAppear {
                        DispatchQueue.main.async {
                            drawing = PKDrawing.loadFromUserDefaults(for: appModel.displayedDate)
                            currentDisplayedDate = appModel.displayedDate
                        }
                    }
                    .onChange(of: appModel.displayedDate) { oldDate, newDate in
                        DispatchQueue.main.async {
                            guard newDate != currentDisplayedDate else { return }
                            drawing.saveToUserDefaults(for: currentDisplayedDate) // Save drawing for the old/current date
                            drawing = PKDrawing.loadFromUserDefaults(for: newDate) // Load drawing for the new date
                            currentDisplayedDate = newDate // Update the current date tracker
                            redoStack.removeAll() // Clear redo stack whenever a new drawing is added
                            undoStack.removeAll() // Clear undo stack whenever a new drawing is added
                        }
                    }
                    .onChange(of: drawing) {
                                captureForUndo()
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
                                                Button(action: undo) {
                                                    Image(systemName: "arrow.uturn.backward.circle.fill")
                                                        
                                                }.foregroundColor(Color.black).font(.title).background(.white).clipShape(Circle()).shadow(radius: 2, x: 3, y: 3)
                                                .disabled(undoStack.isEmpty)

                                                Button(action: redo) {
                                                    Image(systemName: "arrow.uturn.forward.circle.fill")
                                                        
                                                }.foregroundColor(Color.black).font(.title).background(.white).clipShape(Circle()).shadow(radius: 2, x: 3, y: 3)
                                                .disabled(redoStack.isEmpty)
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






