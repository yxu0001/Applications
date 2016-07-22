//
//  ShoppingListViewController.swift
//  ShoppingList
//
//  Created by Yijia Xu on 6/18/16.
//  Copyright © 2016 athenahealth. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListViewController: UIViewController {
    
    var searchController : UISearchController!
    weak var dataMgr: DataManager?
    var shoppingLists: [ShoppingList]!
    var currentShoppingList: ShoppingList?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            self.definesPresentationContext = true
            controller.searchBar.placeholder = "Search or Add an Item"
            controller.searchBar.returnKeyType = .Search
            controller.searchBar.delegate = self
            controller.delegate = self
            
            return controller
            
        })()
        

        self.navigationItem.titleView = searchController.searchBar
        
        self.definesPresentationContext = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchShoppingLists()
    }
    
    private func fetchShoppingLists() {
        let fetchRequest = NSFetchRequest(entityName: "ShoppingList")
        let dateSort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        do {
            let results = try dataMgr?.mainContext?.executeFetchRequest(fetchRequest)
            
            shoppingLists = results as! [ShoppingList]
            currentShoppingList = shoppingLists.isEmpty ? nil : shoppingLists[0]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
}

extension ShoppingListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentShoppingList?.items?.count ?? 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath)
        let shoppintListItem = currentShoppingList?.items?.allObjects[indexPath.row] as? ShoppingListItem
        cell.textLabel?.text = shoppintListItem?.isOf?.name
        return cell
    }

    
    
}

extension ShoppingListViewController: UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UISearchControllerDelegate
    func presentSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(addItemBarButtonTapped))
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
        self.navigationItem.leftBarButtonItem = nil
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    // MARK: - UISearchBar Delegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
    }
    
    func addItemBarButtonTapped() {
        debugPrint("addItemBarButtonTapped")
        if let name = searchController.searchBar.text {
            debugPrint("name = " + name)
            addAnItem(name)
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    func addAnItem(name: String) {
        guard let dataMgr = dataMgr else { return }
        guard let mainContext = dataMgr.mainContext else { return }
//        guard let item = NSEntityDescription.entityForName("Item", inManagedObjectContext: mainContext) else { return }
//        item.name = name
        
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: mainContext) as! Item
        newItem.name = name
        
        let newShoppingListItem = NSEntityDescription.insertNewObjectForEntityForName("ShoppingListItem", inManagedObjectContext: mainContext) as! ShoppingListItem
        newShoppingListItem.isOf = newItem
        
        if let currentShoppingList = currentShoppingList {
            let itemsSet = currentShoppingList.items?.setByAddingObject(newShoppingListItem)
            currentShoppingList.items = itemsSet
        } else {
            let newShoppingList = NSEntityDescription.insertNewObjectForEntityForName("ShoppingList", inManagedObjectContext: mainContext) as! ShoppingList
            let itemsSet = newShoppingList.items?.setByAddingObject(newShoppingListItem)
            newShoppingList.items = itemsSet
            newShoppingList.date = NSDate()
            
            fetchShoppingLists()
        }
        
        dataMgr.saveContext()
        tableView.reloadData()
    }
}
