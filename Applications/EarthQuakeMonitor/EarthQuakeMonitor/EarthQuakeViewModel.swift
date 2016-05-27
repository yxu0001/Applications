//
//  EarthQuakeViewModel.swift
//  EarthQuakeMonitor
//
//  Created by Yijia Xu on 5/27/16.
//

import Foundation

class EarthQuakeViewModel: NSObject {
    lazy var requestMgr = AFRequestManager()
    
    var isSearching = false
    
    var feed: QuakeFeed?
    var filtered: [QuakeFeed.Feature]? {
        didSet {
            filteredFeatureByDate = featuresByDate(isSearching)
        }
    }
    
    var allFeaturesByDate: [NSDate: [QuakeFeed.Feature]]?
    var filteredFeatureByDate: [NSDate: [QuakeFeed.Feature]]?
    
    private func categorizeFeaturesByDate(features: [QuakeFeed.Feature]) -> [NSDate: [QuakeFeed.Feature]]? {
        return features.categorise {
            let timestamp = $0.properties.time // milliseconds
            let datetime = NSDate(timeIntervalSince1970: timestamp! * 0.001)
            
            let calendar = NSCalendar.currentCalendar()
            calendar.timeZone = NSTimeZone(name: "UTC")!
            let components = calendar.components([.Year, .Month, .Day], fromDate: datetime)
            let dateOnly = calendar.dateFromComponents(components)
            
            return dateOnly!
        }
    }
    
    private func featuresByDate(searching: Bool) -> [NSDate: [QuakeFeed.Feature]]? {
        if searching {
            guard let filtered = filtered else { return nil }
            return categorizeFeaturesByDate(filtered)
        } else {
            guard let features = feed?.features else { return nil }
            return categorizeFeaturesByDate(features)
        }
    }
    
    func fetchQuakeData(feedSummaryTimeInterval: FeedSummaryTimeInterval, completion: ((success: Bool, error: NSError?) -> Void)) {
        requestMgr.fetchQuakeSummary(feedSummaryTimeInterval, completion: {
            [unowned self] success, feed, error in
            
            if success {
                self.feed = feed
                self.allFeaturesByDate = self.featuresByDate(false)
                self.filteredFeatureByDate = self.featuresByDate(true)
            } 

            completion(success: success, error: error)
        })
    }
    
    func getFeaturesByDate() -> [NSDate: [QuakeFeed.Feature]]? {
        if isSearching {
            return filteredFeatureByDate
        } else {
            return allFeaturesByDate
        }
    }
    
    func numberOfSections() -> Int {
        guard let featuresByDate = getFeaturesByDate() else { return 0 }
        return featuresByDate.keys.count
    }
    
    func numberOfRowsInSetion(section: Int) -> Int {
        guard let featuresByDate = getFeaturesByDate() else { return 0 }
        let orderedKeys = featuresByDate.keys.sort { $0.compare($1) == .OrderedDescending }
        guard let numberOfRows = featuresByDate[orderedKeys[section]]?.count else { return 0 }
        return numberOfRows
    }


}


// MARK: - Reusable Extensions
public extension SequenceType {
    func categorise<U: Hashable>(@noescape keyFunc: Generator.Element -> U) -> [U: [Generator.Element]] {
        var dict: [U:[Generator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}
