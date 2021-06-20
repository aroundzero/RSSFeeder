//
//  ConfigurationView.swift
//  RSSFeeder
//
//  Created by Dino Franic on 15.06.2021..
//

import SwiftUI

struct ConfigurationView: View {
    @AppStorage("notifications-enabled") var notificationsEnabled: Bool = false
    @AppStorage("feeds-in-app") var feedsInApp: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Toggle("Notifications", isOn: $notificationsEnabled)
                    .padding([.leading, .trailing, .top], 20)
                Toggle("Open feeds in app", isOn: $feedsInApp)
                    .padding([.leading, .trailing, .top], 20)
                    .disabled(true)
                Spacer()
            }.navigationTitle("Configuration")
        }
    }
}

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView()
    }
}
