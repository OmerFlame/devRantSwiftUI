//
//  PreviewTester.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 11/16/20.
//

import SwiftUI

struct PreviewTester: View {
    @Environment(\.viewController) private var viewControllerHolder: ViewControllerHolder
    private var viewController: UIViewController? {
        self.viewControllerHolder.value
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                Text("Hello, World!")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Menu(content: {
                                Button(action: {
                                    
                                }, label: {
                                    HStack {
                                        Text("Settings")
                                        Image(systemName: "gearshape.fill")
                                    }
                                })
                            
                                Button(action: {
                                    
                                }, label: {
                                    HStack {
                                        Text("Log Out")
                                        Image(systemName: "lock.fill")
                                    }
                                })
                            }, label: { Image(systemName: "ellipsis.circle.fill").font(.system(size: 25)) }
                            )
                        }
                        
                        /*ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Test") {
                                //self.test = Bundle.main.url(forResource: "pngTest", withExtension: "png")
                                
                                //let containerController = UINavigationController(rootViewController: UIViewController())
                                //containerController.modalPresentationStyle = .overFullScreen
                                
                                //containerController.didMove(toParent: self.viewController)
                                //self.viewController?.addChild(containerController)
                                //containerController.view.frame = (self.viewController?.view.frame)!
                                //self.viewController?.view.addSubview(containerController.view)
                                //containerController.didMove(toParent: self.viewController)
                                
                                //self.viewController?.present(containerController, animated: true)
                                
                                let previewController = previewTestController()
                                previewController.modalPresentationStyle = .overCurrentContext
                                previewController.didMove(toParent: self.viewController)
                                //previewController.dataSource = previewControllerDataSource()
                                self.viewController?.present(previewController, animated: true)
                                //containerController.present(previewController, animated: true)
                            }
                        }*/
                    }
            }
        }
    }
}

struct PreviewTester_Previews: PreviewProvider {
    static var previews: some View {
        PreviewTester()
    }
}
