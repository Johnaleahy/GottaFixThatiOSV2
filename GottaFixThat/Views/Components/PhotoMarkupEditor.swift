//
//  PhotoMarkupEditor.swift
//  GottaFixThat
//
//  Created on 5/17/26.
//

import SwiftUI
import PencilKit
import os

struct PhotoMarkupEditor: View {
    let sourceImage: UIImage
    let initialDrawingData: Data?
    let onSave: (UIImage, Data?) -> Bool

    @Environment(\.dismiss) private var dismiss
    @State private var drawing = PKDrawing()
    @State private var canvasDisplaySize: CGSize = .zero

    private static let logger = Logger(subsystem: "com.immediac.GottaFixThat", category: "PhotoMarkup")

    private static func debugLog(_ message: String) {
#if DEBUG
        logger.info("\(message, privacy: .public)")
#endif
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                MarkupCanvasView(
                    image: sourceImage,
                    drawing: $drawing,
                    canvasDisplaySize: $canvasDisplaySize
                )
            }
            .navigationTitle("Markup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let drawingData = drawing.dataRepresentation()
                        let annotatedImage = renderedImage()
                        Self.debugLog(
                            "Saving markup. sourcePixels=\(Int(sourceImage.pixelSize.width))x\(Int(sourceImage.pixelSize.height)) renderedPixels=\(Int(annotatedImage.pixelSize.width))x\(Int(annotatedImage.pixelSize.height)) canvasDisplaySize=\(Int(canvasDisplaySize.width))x\(Int(canvasDisplaySize.height)) drawingBytes=\(drawingData.count) approxRenderedMemoryMB=\(annotatedImage.approximateMemoryBytes / 1_048_576)"
                        )
                        if onSave(annotatedImage, drawingData) {
                            dismiss()
                        }
                    }
                }
            }
        }
        .onAppear {
            Self.debugLog(
                "Opening markup editor. sourcePixels=\(Int(sourceImage.pixelSize.width))x\(Int(sourceImage.pixelSize.height)) approxSourceMemoryMB=\(sourceImage.approximateMemoryBytes / 1_048_576) hasInitialDrawing=\(self.initialDrawingData != nil, privacy: .public)"
            )

            if let initialDrawingData,
               let restoredDrawing = try? PKDrawing(data: initialDrawingData) {
                drawing = restoredDrawing
                Self.debugLog("Restored existing drawing. drawingBytes=\(initialDrawingData.count)")
            }
        }
    }

    private func renderedImage() -> UIImage {
        let renderBaseImage = sourceImage.normalizedForStorage()
        let renderSize = renderBaseImage.size
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: renderSize, format: format)
        let exportBounds = CGRect(
            origin: .zero,
            size: canvasDisplaySize == .zero ? renderSize : canvasDisplaySize
        )
        let exportScale = max(
            renderSize.width / max(exportBounds.width, 1),
            renderSize.height / max(exportBounds.height, 1)
        )

        Self.debugLog(
            "Rendering annotated image. basePixels=\(Int(renderBaseImage.pixelSize.width))x\(Int(renderBaseImage.pixelSize.height)) canvasDisplaySize=\(Int(exportBounds.width))x\(Int(exportBounds.height)) exportScale=\(exportScale)"
        )

        return renderer.image { context in
            renderBaseImage.draw(in: CGRect(origin: .zero, size: renderSize))
            let drawingImage = drawing.image(from: exportBounds, scale: exportScale)
            drawingImage.draw(in: CGRect(origin: .zero, size: renderSize))
        }
    }
}

private struct MarkupCanvasView: UIViewRepresentable {
    let image: UIImage
    @Binding var drawing: PKDrawing
    @Binding var canvasDisplaySize: CGSize

    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing, canvasDisplaySize: $canvasDisplaySize)
    }

    func makeUIView(context: Context) -> PKCanvasHostView {
        let view = PKCanvasHostView()
        view.configure(with: image, drawing: drawing, coordinator: context.coordinator)
        return view
    }

    func updateUIView(_ uiView: PKCanvasHostView, context: Context) {
        uiView.updateImage(image)
        if uiView.canvasView.drawing != drawing {
            uiView.canvasView.drawing = drawing
        }
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing
        @Binding var canvasDisplaySize: CGSize

        init(drawing: Binding<PKDrawing>, canvasDisplaySize: Binding<CGSize>) {
            _drawing = drawing
            _canvasDisplaySize = canvasDisplaySize
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing = canvasView.drawing
        }

        func updateCanvasDisplaySize(_ size: CGSize) {
            canvasDisplaySize = size
        }
    }
}

private final class PKCanvasHostView: UIView {
    let imageView = UIImageView()
    let canvasView = PKCanvasView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput

        addSubview(imageView)
        addSubview(canvasView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with image: UIImage, drawing: PKDrawing, coordinator: PKCanvasViewDelegate) {
        updateImage(image)
        canvasView.delegate = coordinator
        canvasView.tool = PKInkingTool(.pen, color: .systemGreen, width: 8)
        canvasView.drawing = drawing
    }

    func updateImage(_ image: UIImage) {
        imageView.image = image
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let fittedFrame = displayedImageFrame(for: imageView.image?.size ?? bounds.size, in: bounds)
        imageView.frame = fittedFrame
        canvasView.frame = fittedFrame
        (canvasView.delegate as? MarkupCanvasView.Coordinator)?.updateCanvasDisplaySize(fittedFrame.size)
    }

    private func displayedImageFrame(for imageSize: CGSize, in bounds: CGRect) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0, bounds.width > 0, bounds.height > 0 else {
            return bounds
        }

        let imageAspectRatio = imageSize.width / imageSize.height
        let boundsAspectRatio = bounds.width / bounds.height

        let fittedSize: CGSize
        if imageAspectRatio > boundsAspectRatio {
            let width = bounds.width
            fittedSize = CGSize(width: width, height: width / imageAspectRatio)
        } else {
            let height = bounds.height
            fittedSize = CGSize(width: height * imageAspectRatio, height: height)
        }

        let origin = CGPoint(
            x: bounds.midX - (fittedSize.width / 2),
            y: bounds.midY - (fittedSize.height / 2)
        )

        return CGRect(origin: origin, size: fittedSize).integral
    }
}
