import SwiftUI
import UIKit
import PencilKit

extension PKDrawing {
    static func loadFromUserDefaults() -> PKDrawing {
        guard let data = UserDefaults.standard.data(forKey: "drawingData"),
              let drawing = try? PKDrawing(data: data) else {
            return PKDrawing()
        }
        return drawing
    }
    
    func saveToUserDefaults() {
        let data = self.dataRepresentation()
        UserDefaults.standard.set(data, forKey: "drawingData")
    }
}

struct CanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Binding var tool: PKTool
    @Binding var isMenuVisible: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = .systemGray // Set the background color to gray
        canvasView.delegate = context.coordinator
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
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
            parent.drawing = canvasView.drawing
        }
        func canvasViewDidBeginDrawing(_ canvasView: PKCanvasView) {
                    parent.isMenuVisible = false
                }
    }
}

import SwiftUI
import UIKit
import PencilKit

// PKDrawing extension and CanvasView code remains unchanged

struct NotesView: View {
    @State private var drawing = PKDrawing()
    @State private var tool: PKTool = PKInkingTool(.monoline, color: .black, width: 2) // Default tool
    @State private var penWidth: CGFloat = 2
    @State private var eraserWidth: CGFloat = 20
    @State private var showPenMenu = false
    @State private var showEraserMenu = false
    @State private var isMenuVisible = false

    var body: some View {
        ZStack {
            CanvasView(drawing: $drawing, tool: $tool, isMenuVisible: $isMenuVisible)
                            .edgesIgnoringSafeArea(.all)
                
            VStack {
                
                HStack {
                    Spacer()
                    VStack {
                        
                        Button(action: {
                            if tool is PKInkingTool {
                                showPenMenu.toggle() // Toggle pen menu visibility
                            } else {
                                // Switch to pen and show its menu
                                self.tool = PKInkingTool(.monoline, color: .black, width: penWidth)
                                
                            }
                        }) {
                            
                            Image(systemName: "pencil.circle.fill").foregroundColor(.white)
                        }
                        // Pen size adjustment menu
                        if showPenMenu {
                            VStack {
                                VerticalSlider(
                                    value: $penWidth,
                                    range: 2...100,
                                    onEditingChanged: { editing in
                                        showPenMenu = editing
                                    }
                                )
                                
                                
                            }
                            .transition(.slide)
                            .animation(.easeOut, value: showPenMenu)
                            .onDisappear {
                                // Update the pen tool with the new width when the menu is closed
                                if tool is PKInkingTool {
                                    self.tool = PKInkingTool(.monoline, color: .black, width: penWidth)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    VStack {
                        
                        Button(action: {
                            if tool is PKEraserTool {
                                showEraserMenu.toggle() // Toggle eraser menu visibility
                            } else {
                                // Switch to eraser and show its menu
                                self.tool = PKEraserTool(.bitmap, width: eraserWidth)
                                
                            }
                        }) {
                            Image(systemName: "eraser.fill").foregroundColor(.white)
                        }
                        // Eraser size adjustment menu
                        if showEraserMenu {
                            VStack {
                                VerticalSlider(
                                    value: $eraserWidth,
                                    range: 20...500,
                                    onEditingChanged: { editing in
                                        showEraserMenu = editing
                                    }
                                )
                               
                                
                            }
                            .transition(.slide)
                            .animation(.easeOut, value: showEraserMenu)
                            .onDisappear {
                                // Update the eraser tool with the new width when the menu is closed
                                if tool is PKEraserTool {
                                    self.tool = PKEraserTool(.bitmap, width: eraserWidth)
                                }
                            }
                            
                        }
                        Spacer()
                    }
                 
                    }.padding()
                    
                Spacer()
            }

        }
        
    }
}


#Preview {
    NotesView()
}
