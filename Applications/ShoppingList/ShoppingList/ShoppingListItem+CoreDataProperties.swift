//
//  ShoppingListItem+CoreDataProperties.swift
//  ShoppingList
//
//  Created by Yijia Xu on 7/20/16.
//  Copyright © 2016 athenahealth. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ShoppingListItem {

    @NSManaged var count: NSNumber?
    @NSManaged var fulfilled: NSNumber?
    @NSManaged var belongsTo: Store?
    @NSManaged var isOf: Item?

}
