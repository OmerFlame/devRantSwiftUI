//
//  ComposeView.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 11/19/20.
//

import SwiftUI

struct ComposeView: View {
    @State var content = ""
    @State var tags = ""
    @Binding var shouldShow: Bool
    @State var shouldShowError = false
    @State var isPosting = false
    @State private var inputImage: UIImage?
    @State var showingImagePicker = false
    
    let isComment: Bool
    let rantID: Int?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                /*TextEditor(text: $contents)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 200)
                    .padding()
                    .border(Color.black, width: 1)
                    .clipShape(RoundedRectangle(cornerRadius: 15))*/
                
                MultilineTextView(placeholder: (self.isComment ? "Add your 2 cents..." : "The rant starts here..."), isComment: self.isComment, text: $content)
                    //.overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray))
                    .frame(height: 250)
                    .padding(.top)
                
                HStack {
                    Text(String((self.isComment ? 1000 : 5000) - content.count))
                        //.padding(.top, 1)
                        .font(.caption)
                        //.padding(.leading)
                    
                    Spacer()
                    
                    Button(action: {
                        
                        if inputImage == nil {
                            self.showingImagePicker.toggle()
                        } else {
                            self.inputImage = nil
                        }
                    }, label: {
                        Label((self.inputImage == nil ? "Attach img/gif" : "Remove image"), systemImage: "photo")
                            .font(.caption)
                    })
                }
                
                if !self.isComment {
                    TextField("Tags (comma separated)", text: $tags)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.top, 10)
                }
                
                Spacer().ignoresSafeArea(.keyboard)
            }
            .padding()
            .navigationBarTitle(Text((self.isComment ? "New Comment" : "New Rant/Story")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.shouldShow = false
                    }, label: {
                        Text("Cancel")
                    }).disabled(isPosting)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.isPosting.toggle()
                        
                        DispatchQueue.global(qos: .userInitiated).async {
                            if self.isComment {
                                let success = APIRequest().postComment(rantID: self.rantID!, content: self.content, image: self.inputImage)
                                
                                DispatchQueue.main.async {
                                    isPosting = false
                                    
                                    if !success {
                                        self.shouldShowError.toggle()
                                    } else {
                                        self.shouldShow = false
                                    }
                                }
                            } else {
                                let rantID = APIRequest().postRant(postType: .rant, content: self.content, tags: self.tags, image: self.inputImage)
                                
                                DispatchQueue.main.async {
                                    isPosting = false
                                    
                                    if rantID == -1 {
                                        self.shouldShowError.toggle()
                                    } else {
                                        self.shouldShow = false
                                    }
                                }
                            }
                        }
                    }, label: {
                        if isPosting {
                            ProgressView()
                        } else {
                            Image(systemName: "paperplane")
                        }
                    }).disabled(isPosting || (self.content.isEmpty && self.inputImage == nil))
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
        }
        //Text(contents)
    }
}

struct MultilineTextView: UIViewRepresentable {
    let placeholder: String
    let isComment: Bool
    @Binding var text: String
    
    var textView = UITextView()

    func makeUIView(context: Context) -> UITextView {
        //let textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
        textView.placeholder = placeholder
        textView.placeholderColor = UITraitCollection.current.userInterfaceStyle == .dark ? UIColor(hex: "464649") : UIColor(hex: "c5c5c7")
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 5
        
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: context.coordinator, action: #selector(Coordinator.doneButtonPressed))
        
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        
        textView.inputAccessoryView = keyboardToolbar
        
        return textView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: MultilineTextView
        
        init(_ parent: MultilineTextView) {
            self.parent = parent
        }
        
        @objc func doneButtonPressed() {
            parent.textView.resignFirstResponder()
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            /*if let onDone = self.onDone, text == "\n" {
                textView.resignFirstResponder()
                onDone()
                return false
            }*/
            
            /*if textView.text.count == 5000 {
                return false
            }*/
            
            if parent.isComment {
                return textView.text.count + (text.count - range.length) <= 1000
            } else {
                return textView.text.count + (text.count - range.length) <= 5000
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.backgroundColor = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
        uiView.placeholderColor = UITraitCollection.current.userInterfaceStyle == .dark ? UIColor(hex: "464649") : UIColor(hex: "c5c5c7")
        uiView.layer.borderColor = UITraitCollection.current.userInterfaceStyle == .dark ? UIColor(hex: "ffffff")!.withAlphaComponent(0.20).cgColor : UIColor(red: 0, green: 0, blue: 0, alpha: 0.20).cgColor
        uiView.layer.borderWidth = 0.333
    }
}

struct ComposeView_Previews: PreviewProvider {
    static var previews: some View {
        ComposeView(shouldShow: .constant(true), isComment: false, rantID: nil)
    }
}
