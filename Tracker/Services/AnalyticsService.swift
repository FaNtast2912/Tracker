//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Maksim Zakharov on 29.01.2025.
//
import AppMetricaCore
import Foundation

struct AnalyticsService {
    
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "47146317-36f9-4ba7-bc61-d88499a46a6f" ) else { return }
        AppMetrica.activate(with: configuration)
    }
    
    func report(event: AppMetricaModel.Event, screen: AppMetricaModel.Screen, item: AppMetricaModel.Item?) {
        var params: [String: Any] = ["event": event.rawValue, "screen": screen.rawValue]
        params["item"] = item?.rawValue
        AppMetrica.reportEvent(name: event.rawValue, parameters: params, onFailure: { (error) in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
