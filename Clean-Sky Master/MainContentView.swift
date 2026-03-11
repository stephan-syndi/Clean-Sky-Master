//
//  MainContentView.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 11.03.26.
//

import SwiftUI
import DarkCoreFramework

struct MainContentView: View {
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        router.changeScreen()
    }

}

#Preview {
    var darkCore = DarkCore.configure(config: Configuration(
        appsDevKey: "TUzHk7rAXDpeyrEfQGLFRD",
        appleAppId: "6759961954"
    ), clearView: ContentView())
   
    MainContentView()
        .environmentObject(darkCore)
}
