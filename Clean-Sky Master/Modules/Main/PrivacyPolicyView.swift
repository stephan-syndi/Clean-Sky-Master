//
//  PrivacyPolicyView.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 11.03.26.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.1, blue: 0.2),
                    Color(red: 0.1, green: 0.15, blue: 0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("PRIVACY POLICY")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible spacer for centering
                    Color.clear
                        .frame(width: 28, height: 28)
                }
                .padding()
                .background(Color.black.opacity(0.3))
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Icon
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color.purple.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "hand.raised.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.purple)
                            }
                            Spacer()
                        }
                        .padding(.top, 20)
                        
                        // Introduction
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Privacy Matters")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Last updated: March 11, 2026")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        // Section 1
                        PolicySection(
                            title: "Information We Collect",
                            icon: "info.circle.fill",
                            color: .blue,
                            content: "We collect minimal information necessary to provide and improve our services. This may include gameplay statistics, device information, and crash reports to enhance your gaming experience."
                        )
                        
                        // Section 2
                        PolicySection(
                            title: "How We Use Your Data",
                            icon: "gearshape.fill",
                            color: .cyan,
                            content: "Your data is used solely to improve game performance, fix bugs, and provide you with the best possible experience. We do not sell or share your personal information with third parties."
                        )
                        
                        // Section 3
                        PolicySection(
                            title: "Data Security",
                            icon: "lock.shield.fill",
                            color: .green,
                            content: "We implement industry-standard security measures to protect your data. All information is encrypted and stored securely on our servers."
                        )
                        
                        // Section 4
                        PolicySection(
                            title: "Third-Party Services",
                            icon: "network",
                            color: .orange,
                            content: "We may use third-party services like Firebase for analytics and crash reporting. These services have their own privacy policies that we encourage you to review."
                        )
                        
                        // Section 5
                        PolicySection(
                            title: "Your Rights",
                            icon: "person.fill.checkmark",
                            color: .purple,
                            content: "You have the right to access, modify, or delete your data at any time. Contact us through the support section if you wish to exercise these rights."
                        )
                        
                        // Section 6
                        PolicySection(
                            title: "Children's Privacy",
                            icon: "figure.2.and.child.holdinghands",
                            color: .pink,
                            content: "Our game is suitable for all ages. We do not knowingly collect personal information from children under 13 without parental consent."
                        )
                        
                        // Contact Info
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Contact Us")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("If you have any questions about this Privacy Policy, please contact us through the app's support section.")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.05))
                        )
                        
                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - Policy Section Component

struct PolicySection: View {
    let title: String
    let icon: String
    let color: Color
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview

#Preview {
    PrivacyPolicyView()
}
