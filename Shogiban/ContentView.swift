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

    @State private var saveSizeInPixel = false
    @State private var boardWidthString: String = ""
    @State private var boardHeightString: String = ""

    @State private var boardBlackName: String = "先手"
    @State private var boardWhiteName: String = "後手"

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
                Spacer()
                Button("save it") {
                    exportingImage = createViewImage()
                    exporterPresented = true
                }
                HStack {
                    Spacer().frame(maxWidth: 10)
                    TextField("SFEN", text: $sfen)
                        .onSubmit {
                            _ = kyokumen.read(sfen: sfen)
                        }
                        .disableAutocorrection(false)
                        .focusable(false)
                    Spacer().frame(maxWidth: 10)
                }
                Toggle(isOn: $reversed) {
                    Text("先後反転")
                }
                shogibanSizeSpecView
                shogibanPlayerNameView

                Spacer()
                Button("盤面を空にする") {
                    kyokumen.clear()
                }
            }
        }
    }

    var shogibanSizeSpecView: some View {
        HStack {
            Spacer().frame(maxWidth: 10)
            Toggle(isOn: $saveSizeInPixel) {
                Text("画面サイズで保存する")
            }

            Text("幅:")
            TextField("width", text: $boardWidthString)
                .focusable(false)
                .frame(width: 50, height: 14)
                .onSubmit {
                    let num = Int(boardWidthString)
                    if let num {
                        boardHeightString = String(Int(Double(num) / 12.0 * 10.4))
                    } else {
                        boardWidthString = ""
                    }
                }

            Text("高さ:")
            TextField("height", text: $boardHeightString)
                .focusable(false)
                .frame(width: 50, height: 14)
                .onSubmit {
                    let num = Int(boardHeightString)
                    if let num {
                        boardWidthString = String(Int(Double(num) / 10.4 * 12.0))
                    } else {
                        boardHeightString = ""
                    }
                }
            Spacer()
        }
    }

    var shogibanPlayerNameView: some View {
        HStack {
            Spacer().frame(maxWidth: 10)
            Text("対局者名: ")
            Text("☗")
            TextField("先手", text: $boardBlackName)
                .focusable(false)
                .frame(width: 70)
                .onSubmit {
                    kyokumen.player(.black, name: boardBlackName)
                }
            Text("☖")
            TextField("後手", text: $boardWhiteName)
                .focusable(false)
                .frame(width: 70)
                .onSubmit {
                    kyokumen.player(.white, name: boardWhiteName)
                }
            Spacer()
        }
    }


    @MainActor func createViewImage() -> Image? {
        let view = ShogibanView(kyokumen: kyokumen)
            .rotationEffect(.degrees(reversed ? 180 : 0))
        let renderer = ImageRenderer(content: view)
        renderer.scale = displayScale
        if saveSizeInPixel {
            renderer.proposedSize = ProposedViewSize(shogiban.banSize)
        } else {
            let width  = Int(boardWidthString)  ?? 600
            let height = Int(boardHeightString) ?? 520
            renderer.proposedSize = ProposedViewSize(width: CGFloat(width), height: CGFloat(height))
        }

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
