//
//  ContentView.swift
//  iMultiply
//
//  Created by Lucas Chae on 5/5/22.
//

import SwiftUI

class UserInput: ObservableObject {
    static let clearCode = String.Element(Unicode.Scalar(7))
    @Published var text1 = ""
    func clear() {
           self.text1 = String(Self.clearCode)
       }
}

struct LevelButton: View {
    let title: String
    @Binding var selectedLevel: String?

    var body: some View {
        let isChosen = title == selectedLevel
        
        HStack {
            Text(title)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(isChosen ? .red : .white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .border(.red, width: 4)
                .foregroundColor(isChosen ? .white : .red)
        }
        .onTapGesture {
            self.selectedLevel = self.title
        }
    }
}


struct CalculatorMenu: View {
    
    @ObservedObject var userInput = UserInput()
    
    // View Controls
    @State private var settingsView = true
    
    @State private var buttonClicked = false
    
    @State private var userScore = 0
        
    // Level Controls
    let integerLevels = Array(2...9)
    let multipliers = Array(1...9).shuffled()
    @State var selectedLevel: String? = nil
    @State private var currentLevel = 0
    @State private var currentQuesiton = 0
    
    // User Inputs
    @State private var userAnswer: Int?
    
    
    var body: some View {
        NavigationView {
            if settingsView  {
                VStack{
                    Text("Choose your level")
                    VStack {
                        HStack {
                            ForEach(integerLevels, id: \.self) { level in
                                LevelButton(title: "\(level)", selectedLevel: self.$selectedLevel)
                            }
                        }
                        .padding()
                        
                        Button("Begin!") {
                            if (selectedLevel != nil) {
                                startNewGame()
                    
                            }
                            
                        }
                        
                    }
                }
                .navigationTitle("iMultiply")
            } else {
                VStack{
                    
                    

                    Spacer()
                    Text("Qeustion \(currentQuesiton + 1)")
                    Spacer()
                    HStack(spacing: 10) {
                        Text("\(currentLevel)")
                        Text("X")
                        Text("\(multipliers[currentQuesiton])")
                    }
//                    TextField("Answer", value: $userAnswer, format: .number)
//                        .padding(.horizontal)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Answer", text: self.$userInput.text1)
                        
                        .padding(.horizontal)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onReceive(self.userInput.text1.publisher) { newValue in
                            if newValue == UserInput.clearCode {
                                self.userInput.text1 = ""
                            }
                        }
                    Button("Submit") {
                        let intAnswer = Int(userInput.text1)
                        userAnswer = intAnswer
                        marker(num1: currentLevel, num2: multipliers[currentQuesiton], userAnswer: userAnswer ?? 0)
                        if (currentQuesiton < 8) {
                            newQuestion()
                        } else {
                            endRound()
                        }
                        self.userInput.clear()
                    }
                    Spacer()
                    Text("User score \(userScore)")

                    Spacer()

                }
                .navigationTitle("Level \(currentLevel)")
            }
        }
    }
    
    func startNewGame() {
        userScore = 0
        settingsView.toggle()
        let temp = Int(selectedLevel!) ?? 0
        currentLevel = temp
    }
    
    func newQuestion() {
        currentQuesiton += 1
        userAnswer = nil
    }
    
    func endRound() {
        currentQuesiton = 0
        settingsView.toggle()

        
    }
    
    func marker(num1: Int, num2: Int, userAnswer: Int) {
        if (num1 * num2 == userAnswer) {
           userScore += 1
        } else {
            userScore -= 1
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorMenu()
    }
}
