//
//  ContentView.swift
//  UWBplugin
//
//  Created by Gustavo Gonzalez on 4/29/25.
//
import SwiftUI


struct ContentView: View {
    @StateObject private var uwbManager = UWBManager()

    var body: some View {
        VStack {
            Text("UWB Distance")
                .font(.headline)
                .padding(.top)

            Text(String(format: "%.2f meters", uwbManager.lastVal))
                .font(.largeTitle)
                .padding()

            Spacer()
        }
        .padding()
    }
}
