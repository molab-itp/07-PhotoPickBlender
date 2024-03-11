//
//  ContentView.swift
//  PhotoPickBlender
//
//  Created by jht2 on 3/24/22.
//

import SwiftUI

struct ContentView: View {
    @State var forePickerIsPresented = false
    @State var backPickerIsPresented = false
    @State var foreResult: [UIImage] = []
    @State var backResult: [UIImage] = []
    @State var blendImage: UIImage? = nil
    
    var body: some View {
        ScrollView {
            
            Button {
                backPickerIsPresented.toggle()
            } label: {
                Text("Select Background")
            }
            ForEach(backResult, id: \.self) { uiImage in
                ImageView(uiImage: uiImage)
            }
            .padding()
            
            Button {
                forePickerIsPresented.toggle()
            } label: {
                Text("Select Foreground")
            }
            
            ForEach(foreResult, id: \.self) { uiImage in
                ImageView(uiImage: uiImage)
            }
            .padding()
            
            if foreResult.count >= 1 && backResult.count >= 1 {
                Button {
                    BlendProcessor.shared.generateBlend(backImage: backResult[0], foreImage: foreResult[0])
                    blendImage = BlendProcessor.shared.photoOutput
                } label: {
                    Text("Generate Blend")
                        .font(.headline)
                        .foregroundColor(Color.blue)
                        .padding(/*@START_MENU_TOKEN@*/.all, 10.0/*@END_MENU_TOKEN@*/)
                }
            }
            
            if let blendImage = blendImage {
                Image(uiImage: blendImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .sheet(isPresented: $forePickerIsPresented) {
            PhotoPicker(pickerResult: $foreResult,
                        isPresented: $forePickerIsPresented)
        }
        .sheet(isPresented: $backPickerIsPresented) {
            PhotoPicker(pickerResult: $backResult,
                        isPresented: $backPickerIsPresented)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
