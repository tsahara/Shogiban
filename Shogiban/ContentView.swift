//
//  ContentView.swift
//  Shogiban
//
//  Created by Tomoyuki Sahara on 2023/10/14.
//

import SwiftUI

struct ContentView: View {
    @State private var exporterPresented = false
    @State private var exportingImage: Image?
    @State private var exportingData: ShogibanImage?
    @State private var kyokumen = Kyokumen()
    @State private var sfen: String = ""
    @State private var reversed: Bool = false

    @Environment(\.displayScale) var displayScale
    @Environment(\.shogiban) var shogiban

    var body: some View {
        HStack {
            ShogibanView(kyokumen: kyokumen)
                .fileExporter(isPresented: $exporterPresented,
                              item: exportingData,
                              contentTypes: [.png],
                              defaultFilename: "Untitled.png",
                              onCompletion: { result in
                })
                .rotationEffect(.degrees(reversed ? 180 : 0))
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Button("save it") {
                    exportingImage = createViewImage()
                    exporterPresented = true
                }
                TextField("SFEN", text: $sfen)
                    .onSubmit {
                        _ = kyokumen.read(sfen: sfen)
                    }
                    .disableAutocorrection(false)
                Toggle(isOn: $reversed) {
                    Text("先後反転")
                }

                Spacer()
                Button("盤面を空にする") {
                    kyokumen.clear()
                }
            }
        }
    }

    @MainActor func createViewImage() -> Image? {

        let view = ShogibanView(kyokumen: kyokumen)
            .rotationEffect(.degrees(reversed ? 180 : 0))
        let renderer = ImageRenderer(content: view)
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
