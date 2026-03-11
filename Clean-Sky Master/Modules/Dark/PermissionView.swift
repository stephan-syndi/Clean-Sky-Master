//
//  PermissionView.swift
//  MixFruits
//
//  Created by Stepan Degtsiaryk on 29.01.26.
//

import SwiftUI
import DarkCoreFramework

struct PermissionView: View {
    var viewModel: PermissionProtocol
    
    init(viewModel: PermissionProtocol) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader{geo in
            
            let isLandscape = geo.size.width > geo.size.height
            ZStack{
                
                VStack{
                    if isLandscape {
                        Spacer()
                        Image(ImageResource.logo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 200)
                        
                    } else
                    {
                        Spacer()
                        Image(ImageResource.logo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 360)
                    }
                    
                    Spacer()
                    Spacer()
                }
                
                LinearGradient(
                    colors: [Color.permissionFade,
                             Color.permissionFade.opacity(0.2)],
                    startPoint: .bottom,
                    endPoint: .center)
                .ignoresSafeArea()
                
                
                
                if isLandscape {
                    HStack{
                        Spacer()
                        VStack(alignment: .leading){
                            Spacer()
                            Text("Allow notifications about bonuses and promos")
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .textCase(.uppercase)
                                .lineLimit(2)
                                .foregroundStyle(.white)
                                .padding(.bottom, 10)
                            
                            Text("Stay tuned with best offers from our casino")
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 18))
                                .italic()
                                .lineLimit(1)
                                .foregroundStyle(.white)
                                .padding(.bottom, 6)
                        }
                        
                        Spacer()
                        
                        VStack{
                            Spacer()
                            Button{
                                viewModel.onRequestNotificationPermission()
                            } label: {
                                Text("Yes, I Want Bonuses!")
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(
                                Image(.permissionBtn)
                                    .resizable(
                                        capInsets: EdgeInsets(
                                            top: 0,
                                            leading: 80,
                                            bottom: 0,
                                            trailing: 80),
                                        resizingMode: .stretch
                                    )
                                    .padding(.horizontal, 60)
                                
                            )
                            .foregroundColor(.permissionApplyFont)
                            
                            Button{
                                viewModel.onSkip()
                            } label: {
                                Text("Skip")
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(
                                ZStack {
                                    Capsule()
                                        .fill(.white.opacity(0.2))
                                }
                                    .padding(.horizontal, 60)
                            )
                            .foregroundColor(Color.permissionText)
                        }
                        Spacer()
                    }
                    
                } else {
                    VStack{
                        //                    Spacer()
                        
                        Spacer()
                        Text("Allow notifications about bonuses and promos")
                            .multilineTextAlignment(.center)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .textCase(.uppercase)
                            .lineLimit(2)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.bottom, 10)
                        
                        Text("Stay tuned with best offers from our casino")
                            .multilineTextAlignment(.center)
                            .font(.system(size: 22))
                            .italic()
                            .foregroundStyle(.white)
                            .padding(.bottom, 10)
                        
                        Button{
                            viewModel.onRequestNotificationPermission()
                        } label: {
                            Text("Yes, I Want Bonuses!")
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(
                            Image(.permissionBtn)
                                .resizable(
                                    capInsets: EdgeInsets(
                                        top: 0,
                                        leading: 80,
                                        bottom: 0,
                                        trailing: 80),
                                    resizingMode: .stretch
                                )
                                .padding(.horizontal, 60)
                            
                        )
                        .foregroundColor(.permissionApplyFont)
                        
                        Button{
                            viewModel.onSkip()
                        } label: {
                            Text("Skip")
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                Capsule()
                                    .fill(.white.opacity(0.2))
                            }
                                .padding(.horizontal, 60)
                        )
                        .foregroundColor(Color.permissionText)
                    }
                    
                }
            }
        }
        .background(
            GeometryReader{ geo in
                Image(ImageResource.back)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
                .ignoresSafeArea()
        )
    }
}

#Preview {
    PermissionView(viewModel: TestPermissionViewModel())
}

class TestPermissionViewModel: PermissionProtocol {
    func onRequestNotificationPermission() {
        
    }
    
    func onSkip() {
        
    }
}
