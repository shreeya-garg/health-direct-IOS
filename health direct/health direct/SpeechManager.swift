//
//  SpeechManager.swift
//  health direct
//
//  Created by Shreeya Garg on 9/29/24.
//

import Foundation
import AVFoundation

class SpeechManager {
    let speechSynthesizer = AVSpeechSynthesizer()
    
    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: .defaultToSpeaker)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    
    func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.prefersAssistiveTechnologySettings = true
        speechSynthesizer.speak(utterance)
    }
}
