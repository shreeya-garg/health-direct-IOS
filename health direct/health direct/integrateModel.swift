import Foundation
import GoogleGenerativeAI

class MedicalAssistant {
    private let generativeModel: GenerativeModel
    
    // Initialize the model with the API key that stays the same
    init() {
        self.generativeModel = GenerativeModel(
            name: "gemini-1.5-flash",
            apiKey: "AIzaSyCNG5vSVGUiXco8hEI4qsX49xs1uBEsStU"
        )
    }
    
    // Method to generate a response with variable user input
    func generateMedicalResponse(userHistory: String, biometricData: String, context: String) async throws -> String {
        let prompt = """
            userHistory: \(userHistory)
            biometric data: \(biometricData).
            context:\(context)
        """
        let response = try await generativeModel.generateContent(prompt)
        
        if let text = response.text {
            return text
        } else {
            return "No response from the model."
        }
    }
}

