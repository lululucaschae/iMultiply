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
        ZStack {
            Circle()
                .strokeBorder(Color.red,lineWidth: 2)
                .background(isChosen ? Circle().foregroundColor(Color.red) : Circle().foregroundColor(Color.white))
            Text(title)
                .frame(maxWidth: .infinity, minHeight: 44)
                .foregroundColor(isChosen ? .white : .red)
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
        .onTapGesture {
            self.selectedLevel = self.title
        }
    }
}




struct CalculatorMenu: View {
    
    // MARK: Properties
    
    @ObservedObject var userInput = UserInput()
    
    // View Controls
    @State private var settingsView = true
    @State private var gameplayView = false
    @State private var resultsView = false
    let keyboardUp = true
    @State private var buttonClicked = false
    
    @State private var userScore = 0
    
    // Level Controls
    let integerLevels = Array(2...9)
    @State private var multipliers = Array(1...9).shuffled()
    @State var selectedLevel: String? = nil
    @State private var currentLevel = 0
    @State private var currentQuesiton = 0
    
    // User Inputs
    @State private var userAnswer: Int?
    
    let returnAlert = "Return to menu?"
    let errorAlert = "Please choose a level"
    
    @State private var returnAlertShowing = false
    @State private var levelAlertShowing = false
    
    
    @FocusState private var isAnswerFocused: Bool
    
    
    var body: some View {
        NavigationView {
            // MARK: Settings
            if settingsView  {
                VStack{
                    Text("Choose your level")
                        .font(.title)
                        .fontWeight(.semibold)
                    VStack {
                        HStack {
                            ForEach(integerLevels, id: \.self) { level in
                                LevelButton(title: "\(level)", selectedLevel: self.$selectedLevel)
                            }
                        }
                        .padding()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color.red,lineWidth: 2)
                                .background(selectedLevel != nil ? Color.red : Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            Text("Begin!")
                                .font(.headline)
                                .foregroundColor(selectedLevel != nil ? Color.white : Color.red)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .padding(.horizontal, 44)
                        .padding()
                        .onTapGesture {
                            if (selectedLevel != nil) {
                                startNewGame()
                            } else {
                                levelAlertShowing.toggle()
                            }
                        }
                    }
                }
                .alert(errorAlert, isPresented: $levelAlertShowing) {
                    Button("Close", role: .cancel) {}
                }
                .navigationTitle("Gugudan!")
            } else if gameplayView
            // MARK: Gameplay
            {
                VStack{
                    Spacer()
                    Text("Question \(currentQuesiton + 1)")
                        .font(.title2)
                        .fontWeight(.semibold)
                    HStack(spacing: 10) {
                        Group {
                            Text("\(currentLevel)")
                            Text("X")
                            Text("\(multipliers[currentQuesiton])")
                        }
                        .font(.largeTitle)
                    }
                    .padding(.vertical, 30)
                    TextField("Answer", text: self.$userInput.text1)
                        .focused($isAnswerFocused)
                        .keyboardType(.numberPad)
                        .padding(.horizontal)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onReceive(self.userInput.text1.publisher) { newValue in
                            if newValue == UserInput.clearCode {
                                self.userInput.text1 = ""
                            }
                        }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.red,lineWidth: 2)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(Color.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .padding(.horizontal, 44)
                    .padding()
                    .onTapGesture {
                        processAnswer()
                    }
                    
                    HStack {
                        Text("Current score")
                        Text("\(userScore)")
                            .fontWeight(.bold)
                            .foregroundColor(Color.red)
                    }
                    Spacer()
                }
                .toolbar {
                    Button("Go back") {
                        returnAlertShowing.toggle()
                    }
                    .tint(Color.red)
                }
                .alert(returnAlert, isPresented: $returnAlertShowing) {
                    Button("Cancel", role: .cancel) {}
                    Button("Menu") {
                        returnToSettings()
                    }
                }
                .navigationTitle("Level \(currentLevel)")
            } else
            // MARK: Results
            {
                VStack{
                    Spacer()
                    Text("Your results for level \(currentLevel)")
                    Spacer()
                    Text("Score: \(userScore)")
                    Spacer()
                    HStack {
                        Button("Play again") {
                            restart()
                        }
                        Button("Go to menu") {
                            returnToSettings()
                        }
                    }
                    Spacer()
                    
                }
                .navigationTitle("Results")
            }
        }
    }
    
    func startNewGame() {
        userScore = 0
        settingsView = false
        gameplayView = true
        let temp = Int(selectedLevel!) ?? 0
        currentLevel = temp
        isAnswerFocused = true
    }
    
    func newQuestion() {
        currentQuesiton += 1
        userAnswer = nil
    }
    
    func showResults() {
        currentQuesiton = 0
        gameplayView = false
        resultsView = true
    }
    
    func restart() {
        resultsView = false
        gameplayView = true
        userScore = 0
        multipliers.shuffle()
        let temp = Int(selectedLevel!) ?? 0
        currentLevel = temp
    }
    
    func returnToSettings() {
        resultsView = false
        gameplayView = false
        settingsView = true
        selectedLevel = nil
    }
    
    func marker(num1: Int, num2: Int, userAnswer: Int) {
        if (num1 * num2 == userAnswer) {
            userScore += 1
        } else {
            userScore -= 1
        }
    }
    
    func processAnswer() {
        let intAnswer = Int(userInput.text1)
        userAnswer = intAnswer
        marker(num1: currentLevel, num2: multipliers[currentQuesiton], userAnswer: userAnswer ?? 0)
        if (currentQuesiton < 8) {
            newQuestion()
        } else {
            showResults()
        }
        self.userInput.clear()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorMenu()
    }
}
