//
//  WrapStack.swift
//  devRantAvatarEditor
//
//  Created by Omer Shamai on 10/1/20.
//

import SwiftUI

struct TagCloudView: View {
    var tags: [String]
    var color: Color

    @State private var totalHeight
          = CGFloat.zero       // << variant for ScrollView/List
        //= CGFloat.infinity   // << variant for VStack

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry, color: self.color)
            }
        }
        .frame(height: totalHeight)// << variant for ScrollView/List
        //.frame(maxHeight: totalHeight) // << variant for VStack
    }

    private func generateContent(in g: GeometryProxy, color: Color) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.tags, id: \.self) { tag in
                self.item(for: tag, color: color)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == self.tags.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tag == self.tags.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func item(for text: String, color: Color) -> some View {
        Text(text)
            .underline()
            .padding(.all, 5)
            .font(.footnote)
            .background(Color.clear)
            //.foregroundColor(Color.black)
            .cornerRadius(5)
            //.colorInvert()
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

struct TestTagCloudView : View {
    var body: some View {
        VStack {
            //Text("Header").font(.largeTitle)
            TagCloudView(tags: ["undefined", "linusgh", "torvalds", "mug", "test", "test 2"], color: Color.red)
            //Text("Some other text")
            //Divider()
            //Text("Some other cloud")
            //TagCloudView(tags: ["Apple", "Google", "Amazon", "Microsoft", "Oracle", "Facebook"])
        }
    }
}

struct WrapStack_Previews: PreviewProvider {
    static var previews: some View {
        TestTagCloudView()
    }
}
