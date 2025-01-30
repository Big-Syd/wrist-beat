//
//  NumberPickerView.swift
//  WristBeat Watch App
//
//  Created by Syd Polk on 1/30/25.
//

import SwiftUI

import SwiftUI

struct NumberPickerView: View {
    @State private var selectedNumber: Int = 60
    
    var body: some View {
        VStack {
            Text("\(selectedNumber)")
                .font(.system(size: 60, weight: .bold))
            Picker("Beats per minute", selection: $selectedNumber) {
                ForEach(60...300, id: \.self) { number in
                    Text("\(number)").tag(number)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 60)
            
        }
    }
}

struct NumberPickerView_Previews: PreviewProvider {
    static var previews: some View {
        NumberPickerView()
    }
}
