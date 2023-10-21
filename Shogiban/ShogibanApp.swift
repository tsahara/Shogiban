//
//  ShogibanApp.swift
//  Shogiban
//
//  Created by 佐原具幸 on 2023/10/14.
//

import SwiftUI

@main
struct ShogibanApp: App {
    @State private var shogiban = Shogiban()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.shogiban, shogiban)
        }
    }
}
