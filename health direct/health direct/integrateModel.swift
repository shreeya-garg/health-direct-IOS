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
        Serve as a medical instruction provider. When a medical emergency occurs, you will provide clear, distinct, and concise steps that bystanders should take to help the situation. You will be given personal userHistory, current biometricData, and potentially additional context about the situation or symptoms. Based on this, you must attempt to identify what might be going wrong and provide a few steps that surrounding individuals, who are not medical professionals, should take to help that person. The userHistory is \(userHistory). The biometric data is \(biometricData). The context is \(context).
        """
        
        let response = try await generativeModel.generateContent(prompt)
        
        if let text = response.text {
            return text
        } else {
            return "No response from the model."
        }
    }
}

