import Foundation
import GoogleGenerativeAI

class MedicalAssistant {
    private let generativeModel: GenerativeModel
    
    // Initialize the model with the API key that stays the same
    init() {
        self.generativeModel = GenerativeModel(
            name: "tunedModels/medical-response-prompt-kvnavv2r69ea",
            apiKey: "AIzaSyCNG5vSVGUiXco8hEI4qsX49xs1uBEsStU"
        )
    }
    
    // Method to generate a response with variable user input
    func generateMedicalResponse(userHistory: String, biometricData: String, context: String) async throws -> String {
        let prompt = """
        You are serving as a medical instruction provider. When a medical emergency occurs, you will provide clear, distinct, and concise steps that bystanders should take to help with the situation. Based on the information given below, identify what might be going on and then provide a few clear steps that surrounding indivuduals should take to help that person while waiting for medical personel to arrive.
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

