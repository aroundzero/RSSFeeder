//
//  AddRSSFeedView.swift
//  RSSFeeder
//
//  Created by Dino Franic on 19.06.2021..
//

import SwiftUI
import FeedKit
import Combine
import os

private let logger = Logger(subsystem: "RSSFeeder", category: "AddRssFeederView")

// TODO This view should be split into view and viewmodel. Currently all logic is implemented in view component (I (Dino) am quite new to CoreData usage and integration :))

struct AddRSSFeedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var url: String = String()
    
    let done = PassthroughSubject<RSSFeed?, Never>()
    
    var body: some View {
        TextField("RSS URL", text: self.$url)
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 50)
            .background(Color.white)
            .cornerRadius(12)
            .padding([.leading, .trailing, .bottom], 20)
            .shadow(radius: 20)
        Button(action: {
            self.fetchRSSFeed()
        }) {
            Text("ADD")
                .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .padding([.leading, .trailing], 20)
        .disabled(self.url.isEmpty)
    }
    
    private func fetchRSSFeed() {
        let parser = FeedParser(URL: URL(string: self.url)!)
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { result in
            self.onRSSFeedFetched(result: result)
        }
    }
    
    private func onRSSFeedFetched(result: Result<Feed, ParserError>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let feed):
                guard let rssFeed = feed.rssFeed else {
                    logger.error("Missing rss feed in parsed feed result")
                    return
                }
                
                self.addRSSFeed(rssFeed)
            case .failure(let error):
                logger.error("Failed to fetch RSS feed from url \(self.url). Error: \(error.localizedDescription)")
                self.done.send(nil)
            }
        }
    }
    
    private func addRSSFeed(_ rssFeed: RSSFeed) {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.name = rssFeed.title
            newItem.details = rssFeed.description
            newItem.url = self.url
            newItem.image = rssFeed.image?.url
            
            do {
                try viewContext.save()
                self.done.send(rssFeed)
            } catch let error {
                logger.error("Failed to store new RSS feed. Error: \(error.localizedDescription)")
                self.done.send(nil)
            }
        }
    }
}

struct AddRSSFeedView_Previews: PreviewProvider {
    static var previews: some View {
        AddRSSFeedView()
    }
}
