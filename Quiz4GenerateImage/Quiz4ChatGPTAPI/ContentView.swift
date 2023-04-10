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
    
    func generateImage(prompt:String) async -> UIImage? {
        guard let openai = openai else {
            return nil
        }
        
        do {
            let params  = ImageParameters(prompt: prompt,
                                          resolution: .medium,
                                          responseFormat: .base64Json)
            let result = try await openai.createImage(parameters: params)
            let data = result.data[0].image
            let image = try openai.decodeBase64Image(data)
            return image
            
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
    @State var image: UIImage?
    
    var body: some View {

            NavigationView {
                    
                    VStack {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                            
                        }
                        else {
                            Text("Type prompt to generate image")
                        }
                        Spacer()
                        TextField("Type prompt here...", text: $userInput).padding(20).textFieldStyle(.roundedBorder)
                        Button("Generate Image!") {
                            
                            if !userInput.trimmingCharacters(in:  .whitespaces).isEmpty  {
                                
                                Task {
                                    let result = await viewModel.generateImage(prompt: userInput)
                                    
                                    if result == nil {
                                        print("Failed Generating Image, Try Again ")
                                    }
                                    self.image = result
                                    
                                    
                                }
                                
                                
                            }
                            
                            
                        }
                        
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("AI Image Generator")
                                .font(.largeTitle.bold())
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
