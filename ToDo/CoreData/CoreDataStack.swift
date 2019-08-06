//
//  CoreDataStack.swift
//  ToDo
//
//  Created by 김은비 on 06/08/2019.
//  Copyright © 2019 김은비. All rights reserved.
//

import Foundation
import CoreData


class CoreDataStack {

    var container: NSPersistentContainer {
        let container = NSPersistentContainer(name: "Todo")
        container.loadPersistentStores { (description, error) in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
        }
        return container
    }

    var managedContext: NSManagedObjectContext {
        return container.viewContext
    }

}
