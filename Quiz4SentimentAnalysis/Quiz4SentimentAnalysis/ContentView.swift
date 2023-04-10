//
//  ContentView.swift
//  Quiz4ChatGPTAPI
//
//  Created by Niyati Belathur on 4/9/23.
//

import SwiftUI
import OpenAIKit


final class ViewModel: ObservableObject {
    private var openai:OpenAI?
    
    func setup() {
          openai = OpenAI(Configuration(organizationId: "Personal", apiKey:"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"))
        
    }
    
    func generateText(prompt:String) async -> String? {
        guard let openai = openai else {
            return nil
        }
        
        do {
            let params  = CompletionParameters(model: "text-davinci-003", prompt: [prompt], maxTokens: 20, temperature: 0.98, topP: 1.0, presencePenalty: 0.0, frequencyPenalty:  0.0)
                                            
            
            
            let result = try await openai.generateCompletion(parameters: params)
            let data = result.choices[0].text.replacingOccurrences(of: "\n", with: " ")
            return data
            
        }
        catch {
            print(String(describing: error))
            return nil
            
        }
        
        
    }
}


struct ContentView: View {
    
    @ObservedObject var viewModel = ViewModel()
    @State var userInput:String = ""
    @State var output: String?
    
    var body: some View {

            NavigationView {
                    
                    VStack {
                        if let output = output {
                            Text(output)
                            
                        }
                        else {
                            Text("Type sentiment prompt")
                        }
                        Spacer()
                        TextField("Type sentiment prompt here...", text: $userInput).padding(20).textFieldStyle(.roundedBorder)
                        Button("Generate Sentiment(s)!") {
                            
                            if !userInput.trimmingCharacters(in:  .whitespaces).isEmpty  {
                                
                                Task {
                                    let result = await viewModel.generateText(prompt: userInput)
                                    
                                    if result == nil {
                                        print("Failed Generating Sentiment, Try Again ")
                                    }
                                    self.output = result
                                    
                                    
                                }
                                
                                
                            }
                            
                            
                        }
                        
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("AI Sentence Completion")
                                .font(.title2)
                                .fontWeight(.bold)
                                .accessibilityAddTraits(.isHeader)
                        }
                    }
                    .onAppear {
                        viewModel.setup()
                    }
                    
                }

                
     
        

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
