//
//  WristBeatView.swift
//  WristBeat Watch App
//
//  Created by Syd Polk on 2/7/25.
//

import SwiftUI

@MainActor
struct WristBeatView: View {
    
    @ObservedObject var viewModel = WristBeatViewModel()
    
    var body: some View {
        VStack {
            Text("\(Int(viewModel.beatsPerMinute))")
                .font(.system(size: 70))
                .focusable(true)
                .digitalCrownRotation($viewModel.beatsPerMinute, from: 60.0, through: 350.0, by: 1.0, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: true)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 0) {

                Button(action: {
                    viewModel.recordTap()
                }) {
                    Image(systemName: "hand.tap.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 55, height: 55)
                        .foregroundColor(.primary)
                        .padding(10)
                }
                .buttonStyle(.borderless)
                .buttonBorderShape(.buttonBorder)

                Button(action: {
                    viewModel.setPlaying()
                }) {
                    Image(systemName: viewModel.isPlaying ? "square.fill" : "play.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 55, height: 55)
                        .foregroundColor(.primary)
                        .padding(10)
                }
                .buttonStyle(.borderless)
                .buttonBorderShape(.buttonBorder)
            }
        }
    }
}

#Preview {
    WristBeatView()
}
