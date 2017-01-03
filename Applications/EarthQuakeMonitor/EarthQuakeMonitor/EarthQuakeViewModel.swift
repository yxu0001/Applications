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
    
    var allFeaturesByDate: [Date: [QuakeFeed.Feature]]?
    var filteredFeatureByDate: [Date: [QuakeFeed.Feature]]?
    
    fileprivate func categorizeFeaturesByDate(_ features: [QuakeFeed.Feature]) -> [Date: [QuakeFeed.Feature]]? {
        return features.categorise {
            let timestamp = $0.properties.time // milliseconds
            let datetime = Date(timeIntervalSince1970: timestamp! * 0.001)
            
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(identifier: "UTC")!
            let components = (calendar as NSCalendar).components([.year, .month, .day], from: datetime)
            let dateOnly = calendar.date(from: components)
            
            return dateOnly!
        }
    }
    
    fileprivate func getAllFeaturesByDate(_ searching: Bool) -> [Date: [QuakeFeed.Feature]]? {
        guard let features = feed?.features else { return nil }
        return categorizeFeaturesByDate(features)
    }
    
    func filterFeaturesByDate(_ searchText: String, scope: String) {
        var dict: [Date: [QuakeFeed.Feature]] = [:]
        
        guard let keys = allFeaturesByDate?.keys else { return }
        
        if scope == "All" {
            if searchText.isEmpty {
                filteredFeatureByDate = allFeaturesByDate
                return
            } else {
                for key in keys {
                    guard let features = allFeaturesByDate?[key] else { continue }
                    var filtered: [QuakeFeed.Feature]?
                    filtered = features.filter{ feature in
                        return feature.properties.title.lowercased().contains(searchText.lowercased())
                    }
                    if let filtered = filtered, filtered.count > 0 {
                        if dict[key] == nil {
                            dict[key] = filtered
                        } else {
                            dict[key]! += filtered
                        }
                    }
                }
            }
        } else if scope == "M4.5 up" {
            for key in keys {
                guard let features = allFeaturesByDate?[key] else { continue }
                var filtered: [QuakeFeed.Feature]?
                if !searchText.isEmpty {
                    filtered = features.filter{ feature in
                        return (feature.properties.mag >= 4.5) && feature.properties.title.lowercased().contains(searchText.lowercased())
                    }
                } else {
                    filtered = features.filter{ feature in
                        return (feature.properties.mag >= 4.5)
                    }
                }
                if let filtered = filtered, filtered.count > 0 {
                    if dict[key] == nil {
                        dict[key] = filtered
                    } else {
                        dict[key]! += filtered
                    }
                }
            }
        }
                
        filteredFeatureByDate = dict
    }
    
    func fetchQuakeData(_ feedSummaryTimeInterval: FeedSummaryTimeInterval, completion: @escaping ((_ success: Bool, _ error: NSError?) -> Void)) {
        requestMgr.fetchQuakeSummary(feedSummaryTimeInterval, completion: {
            [weak self] success, feed, error in
            
            if success {
                self?.feed = feed
                self?.allFeaturesByDate = self?.getAllFeaturesByDate(false)
            }

            completion(success, error)
        })
    }
    
    func getFeaturesByDate() -> [Date: [QuakeFeed.Feature]]? {
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
    
    func numberOfRowsInSetion(_ section: Int) -> Int {
        guard let featuresByDate = getFeaturesByDate() else { return 0 }
        let orderedKeys = featuresByDate.keys.sorted { $0.compare($1) == .orderedDescending }
        guard let numberOfRows = featuresByDate[orderedKeys[section]]?.count else { return 0 }
        return numberOfRows
    }


}


// MARK: - Reusable Extensions
public extension Sequence {
    func categorise<U: Hashable>(_ keyFunc: (Iterator.Element) -> U) -> [U: [Iterator.Element]] {
        var dict: [U:[Iterator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}
