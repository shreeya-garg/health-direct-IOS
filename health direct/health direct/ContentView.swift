//  Created by Shreeya Garg on 9/28/24.

import SwiftUI
import AVFoundation
import emergency
import healthkit


struct ContentView: View {
    @State private var medications: String = ""
    @State private var med_conditions: String = ""
    @State private var age: String = ""
    @State private var sex: String = "Sex"
    @State private var error_msg: String = ""
    @State private var emergency: String = ""
    @State private var med_data: String = ""
    @State private var dailyWaterIntake: String = ""
    @State private var navigateToConfirmation: Bool = false
    
    var sexes = ["Sex", "Female", "Male", "Other"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 228, green:233, blue:237)
                VStack {
                    //                HStack {
                    Image("HealthDirectLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    //                        .imageScale(.small)
                    Text("HealthDirect")
                        .bold()
                        .font(.largeTitle)
                        .padding(.bottom, 10)
                    //                }
                    
                    
                    Text("Please submit the following info to inform emergency instructions: ")
                        .font(.system(size: 14, weight: .light))
                        .padding(.bottom, 10)
                    
                    // medications
                    TextField(
                        "Medications",
                        text: $medications
                    )
                    .cornerRadius(15)
                    .background(Color.white)
                    .shadow(radius: 1)
                    .padding(.bottom, 10)
                    
                    TextField(
                        "Pre-Existing Medical Conditions",
                        text: $med_conditions
                    )
                    .cornerRadius(15)
                    .background(Color.white)
                    .shadow(radius: 1)
                    .padding(.bottom, 10)
                    
                    TextField(
                        "Age",
                        text: $age
                    )
                    .cornerRadius(15)
                    .background(Color.white)
                    .shadow(radius:5)
                    .padding(.bottom, 10)
                    
                    TextField(
                        "Daily Water Intake (cups/day)",
                        text: $dailyWaterIntake
                    )
                    .cornerRadius(15)
                    .background(Color.white)
                    .shadow(radius:5)
                    .padding(.bottom, 10)
                    
                    Picker("Select Sex", selection: $sex) {
                        ForEach(sexes, id: \.self) { sex in
                            Text(sex)
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // Use the menu style
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 1)
                    .padding(.bottom, 10)
                                        
                    NavigationLink(destination: SubmitConfirmationView(), isActive: $navigateToConfirmation) {
                        Button(action: {
                            format_information(medications: medications, med_conditions: med_conditions, age: age, sex: sex, daily_water_intake: dailyWaterIntake)
                            navigateToConfirmation = true // Trigger navigation
                        }) {
                            Image("SubmitButton")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 50)
                                .shadow(radius: 5)
                        }
                    }
                }
                .padding()
            }
        }
    }


}

func format_information(medications: String, med_conditions: String, age: String, sex: String, daily_water_intake: String) {
    var error_msg: String = ""
    var emergency = "fall"
    var med_data = medications + " " + med_conditions + " " + age + " " + sex + " " + daily_water_intake
    
    if (sex == "Sex") {
        error_msg = "Error: Please select either male or female"
    } else {
        error_msg = ""
    }

    let prompt = "You are a medical professional specializing in immediate steps to take after a health emergency. Concisely list essential steps to direct bystanders on what to do to address the emergency: \(emergency). Take into account the following biometrics and medical data: \(med_data)"
    
    print(prompt)

}


struct HomescreenView: View {
    let speechManager = SpeechManager()
    
    var body: some View {
        VStack {
            HStack {
                Image("HealthDirectLogo")
                .resizable()
                .scaledToFit() 
                .frame(width: 100, height: 100)

                Spacer()
            }
            
            HStack {
                Image(systemName: "eyedropper.halffull")
                Text("Blood Pressure: \(systolic)/\(diastolic)")
            }

            HStack {
                Image(systemName: "lungs")
                Text("Respiratory Rate: \(rate)")
            }
            
            HStack {
                Image(systemName: "bandage.fill")
                Text("Medications: \(medications)")
            }

            HStack {
                Image(systemName: "plus.square.fill")
                Text("Pre-existing Medical Conditions: \(med_conditions)")
            }

            HStack {
                Image(systemName: "drop.triangle.fill")
                Text("Daily Water Intake: \(dailyWaterIntake)")
            }
           
            HStack {
                Image(systemName: "heart.person.fill")
                Text("HK Biological Sex: \(HKObjectType.characteristicType(forIdentifier: .biologicalSex))")
            }
            
            HStack {
                Image(systemName: "heart.person.fill")
                Text("Inputted Sex: \(sex)")
            }

            HStack {
                Image(systemName: "eyeglasses")
                Text("Age: \(age)")
            }
            
        }
        .bold
        .padding()
        .foreground(Color(red: 209, blue: 22, green: 8))
        .imageScale(.small)
        
        //VStack {
        //    Text("Thank You!")
        //        .font(.largeTitle)
        //        .padding()
        //    Text("Your information has been submitted.")
        //        .font(.subheadline)
        //        .padding()
        //}
        //.navigationTitle("Confirmation") // Title for the new view
        //
        //Button {
        //    speechManager.speakText("Thank you for submitting your information. Please follow the instructions accordingly.")
        //    print("PRESSED")
        //} label: {
        //    Image("SubmitButton")
        //        .resizable()
        //        .aspectRatio(contentMode: .fit)
        //        .frame(width: 100, height: 50)
        //        .shadow(radius: 5)
        //}
    }
}



//func vocalizer() {
//    // Usage
//    
//    speechManager.configureAudioSession()
//    speechManager.speakText("This is an example of text-to-speech using the iPhone speaker.")
//    print("PRESSED")
//}


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







#Preview {
    ContentView()
}

#Preview {
    SubmitConfirmationView()
}
