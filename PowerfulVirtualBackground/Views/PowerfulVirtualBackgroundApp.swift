//
//  PowerfulVirtualBackgroundApp.swift
//  PowerfulVirtualBackground
//
//  Created by Toshiki Tomihira on 2021/09/18.
//

import SwiftUI

@main
struct PowerfulVirtualBackgroundApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
