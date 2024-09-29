//
//  healthModel.swift
//  health direct
//
//  Created by Shreeya Garg on 9/29/24.
//
import Foundation
import GoogleGenerativeAI

class MedicalAssistant {
    private let generativeModel: GenerativeModel
    
    // Initialize the model with the API key that stays the same
    init() {
        self.generativeModel = GenerativeModel(
            name: "tunedModels/medical-response-prompt-kvnavv2r69ea",
            apiKey: ProcessInfo.processInfo.environment[("GEMINI_API_KEY")] ?? ""
        )
    }
    
    // Method to generate a response with variable user input
    func generateMedicalResponse(userHistory: String, biometricData: String, context: String) async throws -> String {
       
        let prompt = """
        You are a medical instruction provider to help in emergency situations where time is critical.  When a medical emergency occurs, you will solely provide a diagnosis and a few clear, distinct, and concise steps that bystanders should take to help with the situation. Use the info below to figure out the best response. soley provide diagnosis and instructions. 
            userHistory: \(userHistory)
            biometric data: \(biometricData)
            context:\(context)
        """
        let response = try await generativeModel.generateContent(prompt)
        
        if let text = response.text {
            print(text)
            return text
        } else {
            return "No response from the model."
        }
    }
}
