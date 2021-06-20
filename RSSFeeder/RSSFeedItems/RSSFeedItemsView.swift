//
//  RSSFeedItems.swift
//  RSSFeeder
//
//  Created by Dino Franic on 18.06.2021..
//

import SwiftUI
import UIKit
import WebKit
import FeedKit

struct RSSFeedItemsView: View {
    @AppStorage("feeds-in-app") var feedsInApp: Bool = false
    @ObservedObject var viewModel: RSSFeedItemsViewModel
    @State var showWebView: Bool = false
    @State var urlToOpen: String? = String()
    @State var webView: Webview?
    
    let url: String
    let title: String
    
    init(url: String, title: String) {
        self.url = url
        self.title = title
        self.viewModel = RSSFeedItemsViewModel(url: url)
    }
    
    var body: some View {
        ZStack {
            List {
                ForEach(self.viewModel.rssFeedItems.items) { item in
                    HStack {
                        // Image url is stored in item.enclosure?.attributes?.url :/
                        if item.item.enclosure?.attributes?.url != nil {
                            RemoteImage(url: item.item.enclosure!.attributes!.url!)
                                .frame(width: 50, height: 50, alignment: .center)
                                .cornerRadius(50)
                        } else {
                            Image(systemName: "link")
                                .frame(width: 50, height: 50, alignment: .center)
                        }
                        Button(action: {
                            if feedsInApp {
                                self.urlToOpen = item.item.link!
                                self.webView = Webview(url: self.$urlToOpen)
                                self.showWebView = true
                                return
                            }
                            
                            UIApplication.shared.open(URL(string: item.item.link!)!)
                        }, label: {
                            VStack(alignment: .leading) {
                                Text("\(item.item.title!)")
                                    .font(.subheadline)
                                Spacer()
                                Text("\(item.item.description!)")
                                    .font(.caption)
                                    .lineLimit(2)
                            }
                        })
                    }
                }
            }
            ProgressView()
                .opacity(self.viewModel.rssFeedItems.items.count > 0 ? 0.0 : 1.0)
        }
        .sheet(isPresented: self.$showWebView, content: {
            webView
        })
        .navigationTitle(self.title)
    }
}

struct Webview: UIViewRepresentable {
    @Binding var url: String?

    func makeUIView(context: UIViewRepresentableContext<Webview>) -> WKWebView {
        let webview = WKWebView()

        let request = URLRequest(url: URL(string: self.url!)!, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)

        return webview
    }

    func updateUIView(_ webview: WKWebView, context: UIViewRepresentableContext<Webview>) {
        let request = URLRequest(url: URL(string: self.url!)!, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
    }
}

struct RSSFeedItemsView_Previews: PreviewProvider {
    static var previews: some View {
        RSSFeedItemsView(url: "", title: "")
    }
}
