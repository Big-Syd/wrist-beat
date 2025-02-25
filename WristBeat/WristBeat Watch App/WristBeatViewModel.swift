//
//  WristBeatViewModel.swift
//  WristBeat
//
//  Created by Syd Polk on 2/7/25.
//

import SwiftUI

class WristBeatViewModel: ObservableObject {
    @MainActor @Published var beatsPerMinute: Double = 120
    @MainActor @Published var isPlaying: Bool = false
    @MainActor @Published var isMuted: Bool = false
    
    @MainActor var resetTapTask: Task<Void, Never>? = nil
    var taps: [Date] = []
 
    @MainActor
    func setPlaying(_ playing: Bool) {
        self.isPlaying = playing
        self.checkForPlaying()
    }

    @MainActor
    private func checkForPlaying() {
        if !self.isPlaying {
            Task { @MainActor in
                await self.startHapticLoop()
            }
        }
    }
    
    @MainActor
    private func startHapticLoop() async {
        while isPlaying {
            WKInterfaceDevice.current().play(isMuted ? .click : .start)
            try? await Task.sleep(nanoseconds: UInt64((60 * 1_000_000_000) / beatsPerMinute))
        }
    }

    func toggleMute() {
        Task { @MainActor in
            isMuted.toggle()
        }
    }
    
    @MainActor
    func makeResetTask() {
        self.resetTapTask = Task {
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {}
            Task { @MainActor in
                self.taps.removeAll()
            }
        }
    }
    
    func recordTap() {
        let tapTime = Date.now
        if taps.count > 5 {
            taps.remove(at: 0)
        }
        taps.append(tapTime)

        Task { @MainActor in
            self.resetTapTask?.cancel()
            self.resetTapTask = nil
            self.makeResetTask()
        }

        guard taps.count > 1 else { return }
        
        let intervals = zip(taps, taps.dropFirst()).map { $1.timeIntervalSince($0) }
        let averageInterval = intervals.reduce(0, +) / Double(intervals.count)
        let averageIntervalBeatsPerMinute = 60.0 / averageInterval
        Task { @MainActor in
            self.isPlaying = true
            self.checkForPlaying()
            self.beatsPerMinute = averageIntervalBeatsPerMinute
        }
    }
}
