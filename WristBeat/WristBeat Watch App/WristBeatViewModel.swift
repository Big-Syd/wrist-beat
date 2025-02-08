//
//  WristBeatViewModel.swift
//  WristBeat
//
//  Created by Syd Polk on 2/7/25.
//

import AVFAudio
import SwiftUI

class WristBeatViewModel: ObservableObject {
    @MainActor @Published var beatsPerMinute: Double = 120
    @MainActor @Published var isPlaying: Bool = false
    @MainActor @Published var isMuted: Bool = false
 
    func startHapticLoop() {
        Task { @MainActor in
            while isPlaying {
                WKInterfaceDevice.current().play(isMuted ? .click : .start)
                try? await Task.sleep(nanoseconds: UInt64((60 * 1_000_000_000) / beatsPerMinute))
            }
        }
    }

    func toggleMute() {
        Task { @MainActor in
            isMuted.toggle()
        }
    }
    
    func recordTap() {
        
    }
    
}
