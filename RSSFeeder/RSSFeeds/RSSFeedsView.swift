//
//  ContentView.swift
//  RSSFeeder
//
//  Created by Dino Franic on 15.06.2021..
//

import SwiftUI
import CoreData
import Combine
import FeedKit
import os

private let logger = Logger(subsystem: "RSSFeeder", category: "RSSFeedsView")

// TODO This view should be split into view and viewmodel. Currently all logic is implemented in view component (I (Dino) am quite new to CoreData usage and integration :))

struct RSSFeedsView: View {
    @AppStorage("latest-feed-date") var latestFeedDate: String?
    @AppStorage("notifications-enabled") var notificationsEnabled: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    
    
    private var items: FetchedResults<Item>
    
    @State var addNewSheetPresenting: Bool = false
    @State var showRSSFeedItems = false
    @State var selectedItem: Item?
    @State var subscriptions = [AnyCancellable]()
    
    var notificationsManager = NotificationsManager.shared
    var addRSSFeedView = AddRSSFeedView()
    
    var body: some View {
        NavigationView {
            VStack {
                if self.selectedItem != nil {
                    // TODO Check behaviour: From some reason selectedItem can appear without valid url. This usually happens during deletion of certain row by swiping it to the right
                    NavigationLink(destination: RSSFeedItemsView(url: selectedItem!.url ?? "", title: selectedItem!.name ?? ""), isActive: self.$showRSSFeedItems) {
                        EmptyView()
                    }
                    .opacity(0)
                }
                List {
                    ForEach(items) { item in
                        HStack {
                            if item.image != nil {
                                RemoteImage(url: item.image!)
                                    .frame(width: 50, height: 50, alignment: .center)
                                    .cornerRadius(50)
                            } else {
                                Image(systemName: "link")
                                    .frame(width: 50, height: 50, alignment: .center)
                            }
                            Button(action: {
                                self.selectedItem = item
                                self.showRSSFeedItems = true
                            }, label: {
                                VStack(alignment: .leading) {
                                    Text("\(item.name!)")
                                        .font(.headline)
                                        .lineLimit(1)
                                    Text("\(item.details!)")
                                        .font(.subheadline)
                                }
                            })
                            
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("RSS Feeds")
            .navigationBarItems(leading: EditButton(),
                                trailing: Button(action: { self.addNewSheetPresenting = true}, label: {
                                                    Label("Add New", systemImage: "plus") })
            )
            .sheet(isPresented: self.$addNewSheetPresenting, content: {
                self.addRSSFeedView
                    .onReceive(self.addRSSFeedView.done, perform: { rssFeed in
                        if let rssFeed = rssFeed {
                            self.updateLatestFeedDate(newRSSFeed: rssFeed)
                        }
                        self.addNewSheetPresenting = false
                    })
            })
            .onReceive(self.notificationsManager.backgroundTimeApproved, perform: { value in
                if self.notificationsEnabled {
                    self.checkForNewFeeds()
                }
            })
        }
    }
    
    private func updateLatestFeedDate(newRSSFeed: RSSFeed) {
        guard let newRSSFeedDate = newRSSFeed.pubDate else {
            logger.info("Missing date in newly added RSS feed")
            return
        }

        guard let latestFeedDateString = self.latestFeedDate else {
            self.latestFeedDate = newRSSFeedDate.description
            return
        }

        guard let latestFeedDate = latestFeedDateString.toDate() else {
            logger.info("Failed to parse String date to Date object")
            return
        }

        if latestFeedDate < newRSSFeedDate {
            self.latestFeedDate = newRSSFeedDate.description
        }
    }
    
    func checkForNewFeeds() {
        guard let latestFeedDateString = self.latestFeedDate else {
            return
        }

        for item in items {
            let sub = self.fetchRSSFeedItems(rssFeedUrl: item.url!).sink(receiveValue: { feed in
                guard let feed = feed else {
                    logger.error("RSS feed not received")
                    return
                }
                
                guard let feedDate = feed.pubDate else {
                    logger.info("RSS feed missing date")
                    return
                }
                
                guard let latestFeedDate = latestFeedDateString.toDate() else {
                    return
                }
                
                if feedDate > latestFeedDate {
                    self.updateLatestFeedDate(newRSSFeed: feed)
                    self.notificationsManager.scheduleNotification(title: "RSS Feed Updates", description: "\(item.name!) has some new news")
                }
            })

            self.subscriptions.append(sub)
        }
    }
    
    private func fetchRSSFeedItems(rssFeedUrl: String) -> AnyPublisher<RSSFeed?, Never> {
        return Deferred {
            Future<RSSFeed?, Never> { promise in
                guard let url = URL(string: rssFeedUrl) else {
                    logger.error("Not a valid url string: \(rssFeedUrl)")
                    return
                }
                
                let parser = FeedParser(URL: url)
                parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { result in
                    switch result {
                    case .success(let feed):
                        promise(.success(feed.rssFeed!))
                    case .failure(let error):
                        logger.error("Failed to fetch RSS feeds from url \(rssFeedUrl). Error: \(error.localizedDescription)")
                        promise(.success(nil))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch let error {
                logger.error("Failed to delete RSS feed from view context. Error: \(error.localizedDescription)")
            }
        }
    }
}
