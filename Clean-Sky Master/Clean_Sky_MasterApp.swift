//
//  Clean_Sky_MasterApp.swift
//  Clean-Sky Master
//
//  Created by Stepan Degtsiaryk on 27.02.26.
//

import SwiftUI
import DarkCoreFramework

@main
struct Clean_Sky_MasterApp: App {
    @UIApplicationDelegateAdaptor(DarkAppDelegate.self) var appDelegate
    let config = Configuration(
        appsDevKey: "TUzHk7rAXDpeyrEfQGLFRD",
        appleAppId: "6759961954",
        endpoint: "https://clean-skymaster.com",
        firebaseGCMSenderId: "954908416463"
    )

    private let router: AppRouter
    
    init(){
        print("👉 init MyApp")
        
        router = DarkCore.configure(config: config, clearView: ContentView())
        
        router.setScreen(screen: .clear, view: ContentView())
        router.setScreen(screen: .curtain, view: CurtainView())
        router.setScreen(screen: .permission, view: PermissionView(viewModel: router.getPermissionViewModel()))
        router.setScreen(screen: .internet, view: InternetAlertView())
        
        appDelegate.router = router
    }
    
    var body: some Scene {
        WindowGroup {
            MainContentView()
                .environmentObject(router)
        }
    }
}
