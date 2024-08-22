# SwiftScissor
![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-Support-orange?style=flat-square)
![License](https://img.shields.io/badge/License-Apache%202.0-blue?style=flat-square)
![iOS](https://img.shields.io/badge/iOS-17.0%2B-blue?style=flat-square&logo=apple)
![Visitors](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2FYOURUSERNAME%2FYOURREPO&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=visitors&edge_flat=false)
![GitHub](https://img.shields.io/github/downloads/ksj0109188/SwiftScissor/total?label=SPM%20installs)

# Introduction
An open-source library that provides an easy image cropping feature in a View format for SwiftUI without the need for UIKit connections.
Implement image cropping functionality easily in SwiftUI.

<Table align = "center">
  <tr>
      <td><img src="https://github.com/user-attachments/assets/b3f86c84-743a-4d30-b798-b26db1760a26" width="200" alt="Crop"/></td>
      <td><img src="https://github.com/user-attachments/assets/c8a5cabd-ba07-43e5-9b4e-feb21e8f2c58" width="200" alt="CropMove"/></td>
  </tr>
</Table>

# INSTALLING
 ``` swift
URL : https://github.com/ksj0109188/SwiftScissor.git
```
### STEP 1
To install SwiftScsissor using [Swift Package Manager](https://github.com/apple/swift-package-manager)
### STEP 2
you can follow the [tutorial published by Apple](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) using the URL for this repo


# Examples
CropImageView is the core View.
The constructor takes the original image to be cropped and returns the result through an escape closure after cropping is complete. The user receives the image through the completion closure.
Please note that it returns an optional UIImage in case of failure.

``` swift
   public init(originImage: UIImage, onCrop: @escaping (UIImage?) -> Void) {
        self.originImage = originImage
        self.onCrop = onCrop
    }
```

Here's an example of using CropImageView:
``` swift
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
```

# Contact
### Discord: seongjun9068

# Contribution & Bug Fixes
### Feel free to create Issues and PRs at any time
