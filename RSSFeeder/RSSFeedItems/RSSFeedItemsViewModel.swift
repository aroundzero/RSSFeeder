//
//  RSSFeedItemsManager.swift
//  RSSFeeder
//
//  Created by Dino Franic on 18.06.2021..
//

import Foundation
import Combine
import FeedKit
import os

private let logger = Logger(subsystem: "RSSFeeder", category: "RSSFeedItemsViewModel")

class RSSFeedItemsViewModel: ObservableObject
{
    @Published var rssFeedItems: RSSFeedItems = RSSFeedItems(items: [])
    
    var subscriptions: [AnyCancellable] = []
    let url: String
    
    init(url: String) {
        self.url = url
        
        let subscription = self.fetchRSSFeedItems().sink(receiveValue: { rssFeed in
            self.transformRSSFeed(rssFeed)
        })
        
        subscriptions.append(subscription)
    }
    
    private func fetchRSSFeedItems() -> AnyPublisher<RSSFeed?, Never> {
        return Deferred {
            Future<RSSFeed?, Never> { promise in
                guard let url = URL(string: self.url) else {
                    logger.error("Not a valid url string: \(self.url)")
                    promise(.success(nil))
                    return
                }
                
                let parser = FeedParser(URL: url)
                parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { result in
                    switch result {
                    case .success(let feed):
                        promise(.success(feed.rssFeed!))
                    case .failure(let error):
                        logger.error("Failed to fetch RSS feeds from url \(self.url). Error: \(error.localizedDescription)")
                        promise(.success(nil))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func transformRSSFeed(_ rssFeed: RSSFeed?) {
        guard let rssFeed = rssFeed else {
            logger.error("Fetch RSS feeds failed, received nil")
            return
        }
        
        let items = rssFeed.items
        let identifiableRSSFeedsItems =  items!.enumerated().compactMap{
            IdentifiableRSSFeedItem(item: $0.element, id: $0.offset)
        }
        
        self.setRSSFeedItems(RSSFeedItems(items: identifiableRSSFeedsItems))
    }
    
    private func setRSSFeedItems(_ rssFeedItems: RSSFeedItems) {
        DispatchQueue.main.async {
            self.rssFeedItems = rssFeedItems
        }
    }
}
