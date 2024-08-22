//
//  SwiftUIView.swift
//  
//
//  Created by 김성준 on 8/21/24.
//

import SwiftUI
import SwiftScissor

struct ContentView: View {
    @State private var image = UIImage(named: "yourImage")!
    @State private var cropped: UIImage?
    @State private var ispresent = false
    
    var body: some View {
        VStack {
            Button(action: {
                ispresent.toggle()
            }, label: {
                Text("crop")
            })
            if let image = cropped {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .border(Color.black, width: 1)
            }
            
        }
        .sheet(isPresented: $ispresent, content: {
            CropImageView(originImage: image) { cropped in
                self.cropped = cropped
            }
        })
        .padding()
    }
}
