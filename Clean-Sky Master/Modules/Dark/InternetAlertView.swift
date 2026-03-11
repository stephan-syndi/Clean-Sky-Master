//
//  InternetAlertView.swift
//  MixFruits
//
//  Created by Stepan Degtsiaryk on 29.01.26.
//

import SwiftUI

struct InternetAlertView: View {
    var body: some View {
        ZStack{
            VStack{
                ZStack{
                    Image(ImageResource.popup)
                        .resizable(
                            capInsets: EdgeInsets(top: 40, leading: 40, bottom: 40, trailing: 40),
                            resizingMode: .stretch
                        )
                        .frame(width: 280, height: 200)
              }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
        .background{
            GeometryReader{ geo in
                Image(ImageResource.back)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    InternetAlertView()
}
