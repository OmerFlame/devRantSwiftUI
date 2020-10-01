//
//  UndismissableSheet.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/13/20.
//

import SwiftUI

struct ModalView<T: View>: UIViewControllerRepresentable {
    let view: T
    
    @Binding var isSheetView: Bool
    let onDismissalAttempt: (() -> ())?
    
    func makeUIViewController(context: Context) -> UIHostingController<T> {
        UIHostingController(rootView: view)
    }

    func updateUIViewController(_ uiViewController: UIHostingController<T>, context: Context) {
        uiViewController.parent?.presentationController?.delegate = context.coordinator
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        let modalView: ModalView

        init(_ modalView: ModalView) {
            self.modalView = modalView
        }

        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
            !modalView.isSheetView
        }

        func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
            modalView.onDismissalAttempt?()
        }
    }
}

extension View {
    func presentation(isSheet: Binding<Bool>, onDismissalAttempt: (() -> ())? = nil) -> some View {
        ModalView(view: self, isSheetView: isSheet, onDismissalAttempt: onDismissalAttempt)
    }
}
