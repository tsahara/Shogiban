//
//  ContentView.swift
//  Shogiban
//
//  Created by 佐原具幸 on 2023/10/14.
//

import SwiftUI

struct ContentView: View {
    @State private var exporterPresented = false
    @State private var exportingImage: Image?
    @State private var exportingData: ShogibanImage?

    @Environment(\.displayScale) var displayScale
    @Environment(\.shogiban) var shogiban

    let shogibanView = ShogibanView(kyokumen: Kyokumen())

    var body: some View {
        HStack {
            shogibanView
                .fileExporter(isPresented: $exporterPresented,
                              item: exportingData,
                              contentTypes: [.png],
                              defaultFilename: "Untitled.png",
                              onCompletion: { result in
                })
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Button("save it") {
                    exportingImage = createViewImage()
                    exporterPresented = true
                }
            }
        }
        .padding()
    }

    @MainActor func createViewImage() -> Image? {
        let renderer = ImageRenderer(content: shogibanView)
        renderer.scale = displayScale
        renderer.proposedSize = ProposedViewSize(shogiban.banSize)

        guard let nsImage = renderer.nsImage else { return nil }
        exportingData = ShogibanImage(nsImage: nsImage)

        return Image(nsImage: nsImage)
    }
}

struct ShogibanImage: Transferable {
    let nsImage: NSImage

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { shogibanImage in
            return NSBitmapImageRep(data: shogibanImage.nsImage.tiffRepresentation!)?
                .representation(using: .png, properties: [:]) ?? Data()
        }
    }
}

#Preview {
    ContentView()
}
