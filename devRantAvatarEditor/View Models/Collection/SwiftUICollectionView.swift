//
//  SwiftUICollectionView.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 9/15/20.
//

import SwiftUI
import UIKit

typealias CollectionViewElementSize<Elements> = [Elements.Element.ID: CGSize] where Elements: RandomAccessCollection, Elements.Element: Identifiable

struct SwiftUICollectionView<Elements, Content>: View where Elements: RandomAccessCollection, Content: View, Elements.Element: Identifiable
{
    private var layout: CollectionViewLayout
    private var contentView: (Elements.Element) -> Content
    private var pagedCollection: PagedRandomAccessCollection<Elements>
    
    @State private var sizes: CollectionViewElementSize<Elements> = [:]
    
    init(data: Elements, layout: CollectionViewLayout, contentView: @escaping (Elements.Element) -> Content) {
        self.pagedCollection = PagedRandomAccessCollection<Elements>(collection: data)
        self.layout = layout
        self.contentView = contentView
    }
    
    init(pagedData: PagedRandomAccessCollection<Elements>, layout: CollectionViewLayout, contentView: @escaping (Elements.Element) -> Content) {
        self.layout = layout
        self.contentView = contentView
        self.pagedCollection = pagedData
    }
    
    var body: some View {
        GeometryReader { proxy in
            
        }
    }
    
    private func bodyFor(
        _ layout: CollectionViewLayout,
        containerSize: CGSize,
        offsets: CollectionViewElementSize<Elements>
    ) -> some View {
        switch layout {
        case .singleLine:
            return AnyView(singleLineLayoutBody(containerSize: containerSize, offsets: offsets))
            
        case .flow:
            return AnyView(flowLayoutBody(containerSize: containerSize, offsets: offsets))
            
        case .multiLine(let numberOfLines):
            return AnyView(multiLineLayoutBody(containerSize: containerSize,
                                               offsets: offsets,
                                               lines: numberOfLines))
        }
    }
    
    private func flowLayoutBody(
        containerSize: CGSize,
        offsets: CollectionViewElementSize<Elements>
    ) -> some View {
        let maxOffset = offsets.map { $0.value.height }.max()
        let padding = maxOffset == nil ? CGFloat.zero : maxOffset! - 3 * containerSize.height / 4
        self.pagedCollection.canGetNextPage = true
        return ScrollView {
            ZStack(alignment: .topLeading) {
                ForEach(self.pagedCollection.dataDisplayed) {
                    PropagateSize(content: self.contentView($0).embeddedInNavigationLink, id: $0.id)
                        .offset(offsets[$0.id] ?? CGSize.zero)
                        .animation(.default)
                        .onFrameChange { frame in
                            if -frame.origin.y > padding && self.pagedCollection.canGetNextPage {
                                self.pagedCollection.nextPage()
                            }
                        }
                }
                Color.clear.frame(width: containerSize.width, height: containerSize.height)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: padding, trailing: 0))
        }
        .onPreferenceChange(CollectionViewSizeKey<Elements.Element.ID>.self) {
            self.sizes = $0
        }
    }
    
    private func singleLineLayoutBody(
        containerSize: CGSize,
        offsets: CollectionViewElementSize<Elements>
    ) -> some View {
        let maxOffset = offsets.map { $0.value.width }.max()
        let padding = maxOffset == nil ? CGFloat.zero : maxOffset!
        self.pagedCollection.canGetNextPage = true
        return ScrollView(.horizontal) {
            ZStack(alignment: .topLeading) {
                ForEach(pagedCollection.dataDisplayed) {
                    PropagateSize(content: self.contentView($0).embeddedInNavigationLink, id: $0.id)
                        .offset(offsets[$0.id] ?? CGSize.zero)
                        .animation(.default)
                        .onFrameChange { frame in
                            if -frame.origin.x > padding && self.pagedCollection.canGetNextPage {
                                self.pagedCollection.nextPage()
                            }
                        }
                }
                Color.clear.frame(width: containerSize.width, height: containerSize.height)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: padding))
        }
        .onPreferenceChange(CollectionViewSizeKey<Elements.Element.ID>.self) {
            self.sizes = $0
        }
    }
    
    private struct MultilineCollectionColumn<Elements>: Identifiable where Elements: RandomAccessCollection, Elements.Element: Identifiable {
        var id: Elements.Element.ID
        var elements: [Elements.Element]
    }
    
    private struct MultilineCollectionColumnView<Elements, Cell>: View where Elements: RandomAccessCollection, Cell: View, Elements.Element: Identifiable {
        let column: MultilineCollectionColumn<Elements>
        let cell: (Elements.Element) -> Cell
        
        var body: some View {
            HStack {
                VStack(spacing: 10) {
                    ForEach(column.elements) {
                        self.cell($0).embeddedInNavigationLink
                    }
                }
                Divider()
            }
        }
    }
    
    private func multiLineLayoutBody(
        containerSize: CGSize,
        offsets: CollectionViewElementSize<Elements>,
        lines: Int
    ) -> some View {
        let columns = pagedCollection.dataDisplayed.split(size: lines).map {
            return MultilineCollectionColumn<Elements>(id: $0.first!.id, elements: Array($0))
        }
        let maxOffset = offsets.map { $0.value.width }.max()
        let padding = maxOffset == nil ? CGFloat.zero : maxOffset! - 3 * containerSize.width / 4
        self.pagedCollection.canGetNextPage = true
        return ScrollView(.horizontal) {
            ZStack(alignment: .topLeading) {
                ForEach(columns) {
                    PropagateSize(
                        content: MultilineCollectionColumnView(
                            column: $0,
                            cell: self.contentView
                        ),
                        id: $0.id
                    )
                    .offset(offsets[$0.id] ?? CGSize.zero)
                    .animation(.default)
                    .onFrameChange { frame in
                        if -frame.origin.x > padding && self.pagedCollection.canGetNextPage {
                            self.pagedCollection.nextPage()
                        }
                    }
                }
                Color.clear.frame(width: containerSize.width, height: containerSize.height)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: padding))
        }
        .onPreferenceChange(CollectionViewSizeKey<Elements.Element.ID>.self) {
            self.sizes = $0
        }
    }
    
    private struct PropagateSize<V: View, ID: Hashable>: View {
        var content: V
        var id: ID
        var body: some View {
            content.background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: CollectionViewSizeKey<ID>.self, value: [self.id: proxy.size])
                }
            )
        }
    }
    
    private struct CollectionViewSizeKey<ID: Hashable>: PreferenceKey {
        typealias Value = [ID: CGSize]
        
        static var defaultValue: [ID : CGSize] { [:] }
        static func reduce(value: inout [ID : CGSize], nextValue: () -> [ID : CGSize]) {
            value.merge(nextValue(), uniquingKeysWith: { $1 })
        }
    }
}
