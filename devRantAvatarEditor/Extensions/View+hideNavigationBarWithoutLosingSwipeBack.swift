//
//  View+hideNavigationBarWithoutLosingSwipeBack.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/30/20.
//

import Foundation
import SwiftUI

extension View {
    func hideNavigationViewWithoutLosingSwipeBack(_ hidden: Bool) -> some View {
        return background(NavigationConfigurator(hidden: hidden))
    }
}

private struct NavigationConfigurator: UIViewControllerRepresentable {
    let hidden: Bool
    
    class Coordinator: NSObject {
        weak var navigationController: UINavigationController?
        
        deinit {
            navigationController?.navigationBar.isHidden = false
        }
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        return UIViewController()
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        uiViewController.navigationController?.navigationBar.isHidden = hidden
        context.coordinator.navigationController = uiViewController.navigationController
    }
}
