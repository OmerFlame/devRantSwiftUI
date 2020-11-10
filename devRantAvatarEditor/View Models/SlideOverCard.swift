//
//  SlideOverCard.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 11/10/20.
//

import SwiftUI

struct Handle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .frame(width: 40, height: 5)
            .foregroundColor(Color.secondary)
            .padding(5)
    }
}

struct SlideOverCard<Content: View>: View {
    @GestureState private var dragState = DragState.inactive
    @State var position = CardPosition.top
    
    var content: () -> Content
    
    var body: some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, transaction in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)
        
        return Group {
            Handle()
            self.content()
        }
        .frame(height: UIScreen.main.bounds.size.height)
        .background(Color(.systemBackground))
        .cornerRadius(10.0)
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
        .offset(y: self.position.rawValue + self.dragState.translation.height)
        .animation(self.dragState.isDragging ? nil : .interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
        .gesture(drag)
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
        let verticalDirection = drag.predictedEndLocation.y - drag.location.y
        let cardTopEdgeLocation = self.position.rawValue + drag.translation.height
        let positionAbove: CardPosition
        let positionBelow: CardPosition
        let closestPosition: CardPosition
        
        if cardTopEdgeLocation <= CardPosition.middle.rawValue {
            positionAbove = .top
            positionBelow = .middle
        } else {
            positionAbove = .middle
            positionBelow = .bottom
        }
        
        if (cardTopEdgeLocation - positionAbove.rawValue) < (positionBelow.rawValue - cardTopEdgeLocation) {
            closestPosition = positionAbove
        } else {
            closestPosition = positionBelow
        }
        
        if verticalDirection > 0 {
            self.position = positionBelow
        } else if verticalDirection < 0 {
            self.position = positionAbove
        } else {
            self.position = closestPosition
        }
    }
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
            
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
            
        case .dragging:
            return true
        }
    }
}

enum CardPosition: CGFloat {
    case top = 100
    case middle = 500
    case bottom = 850
}
