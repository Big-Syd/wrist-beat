//
//  ContentView.swift
//  WristBeat Watch App
//
//  Created by Syd Polk on 1/30/25.
//

import SwiftUI

struct TempoPicker: View {
    @State private var selectedNumber: Int = 120

    var body: some View {
        Picker(selection: $selectedNumber, label: EmptyView()) {
            ForEach(60...300, id: \.self) { number in
                Text("\(number)").tag(number)
                    .font(.system(size: 30))
            }
        }
        .pickerStyle(.wheel)
        .frame(height: 70)
    }
}

#Preview {
    TempoPicker()
}
