//
//  EarthQuakeServiceConfig.swift
//  EarthQuakeMonitor
//
//  Created by Yijia Xu on 4/11/16.
//

import Foundation

struct Config {
    var scheme = "http"
    var host = "earthquake.usgs.gov"
    var endpoint = "earthquakes/feed/v1.0"
}

enum FeedSummaryTimeInterval: String {
    case Hour = "significant_hour.geojson"
    case Day = "significant_day.geojson"
    case Week = "significant_week.geojson"
    case Month = "significant_month.geojson"
    case AllDay = "all_day.geojson"
    case AllWeek = "all_week.geojson"
    case AllMonth = "all_month.geojson"
    case FourPointFiveDay = "4.5_day.geojson"
    case FourPointFiveWeek = "4.5_week.geojson"
    case FourPointFiveMonth = "4.5_month.geojson"
}

