//
//  RSSFeederApp.swift
//  RSSFeeder
//
//  Created by Dino Franic on 15.06.2021..
//

import SwiftUI
import FeedKit
import BackgroundTasks
import Combine
import os

private let logger = Logger(subsystem: "RSSFeeder", category: "RSSFeederApp")

@main
struct RSSFeederApp: App {
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabView {
                RSSFeedsView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem { Label("RSS Feeds", systemImage: "link") }
                ConfigurationView()
                    .tabItem { Label("Configuration", systemImage: "gear") }
            }
        }
        .onChange(of: scenePhase) { phase in
            self.onScenePhaseChanged(phase: phase)
        }
    }
    
    private func onScenePhaseChanged(phase: ScenePhase) {
        switch phase {
            case .active:
                UIApplication.shared.applicationIconBadgeNumber = 0
        default:
            logger.info("App whent to background or inactive state")
        }
    }
}

class IdentifiableRSSFeedItem: Identifiable
{
    var item: RSSFeedItem
    var id: Int
    
    init(item: RSSFeedItem, id: Int) {
        self.item = item
        self.id = id
    }
}

class RSSFeedItems: ObservableObject
{
    @Published var items: [IdentifiableRSSFeedItem]
    
    init(items: [IdentifiableRSSFeedItem]) {
        self.items = items
    }
}
