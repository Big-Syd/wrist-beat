//
//  WristBeatViewModel.swift
//  WristBeat
//
//  Created by Syd Polk on 2/7/25.
//

import HealthKit
import SwiftUI

class WristBeatViewModel: ObservableObject {
    @MainActor @Published var beatsPerMinute: Double = {
        if UserDefaults.standard.object(forKey: "beatsPerMinute") != nil {
            return UserDefaults.standard.double(forKey: "beatsPerMinute")
        }
        return 120.0
    }() {
        didSet {
            UserDefaults.standard.set(beatsPerMinute, forKey: "beatsPerMinute")
        }
    }
    @MainActor @Published var isPlaying: Bool = false
    
    @MainActor var tapTask: Task<Void, Never>? = nil
    @MainActor var resetTapTask: Task<Void, Never>? = nil
    @MainActor var healthStore = HKHealthStore()
    @MainActor var workoutSession: HKWorkoutSession?
    
    var taps: [Date] = []

    @MainActor
    func setPlaying() {
        self.isPlaying.toggle()
        self.checkForPlaying()
    }

    @MainActor
    private func checkForPlaying() {
        if self.isPlaying {
            if let tapTask, !tapTask.isCancelled {
                return
            }
            tapTask = Task { @MainActor in
                await self.startHapticLoop()
            }
        } else {
            workoutSession?.end()
            tapTask?.cancel()
            tapTask = nil
        }
    }
    
    @MainActor
    private func startHapticLoop() async {
        let config = HKWorkoutConfiguration()
        config.activityType = .other
        config.locationType = .unknown
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            workoutSession?.startActivity(with: Date()) // Keeps the app running
            while isPlaying {
                WKInterfaceDevice.current().play(.start)
                try? await Task.sleep(nanoseconds: UInt64((60 * 1_000_000_000) / beatsPerMinute))
            }
        } catch {
            print("Failed to start workout session: \(error)")
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
