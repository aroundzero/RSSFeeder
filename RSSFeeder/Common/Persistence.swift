//
//  Persistence.swift
//  RSSFeeder
//
//  Created by Dino Franic on 15.06.2021..
//

import CoreData
import os

private let logger = Logger()

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "RSSFeeder")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                logger.error("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
