//
//  SheduleTransformer.swift
//  Tracker
//
//  Created by Maksim Zakharov on 26.12.2024.
//
import Foundation

@objc
final class ScheduleTransformer: ValueTransformer {
    
    static func register() {
        ValueTransformer.setValueTransformer(
            ScheduleTransformer(),
            forName: NSValueTransformerName(String(describing: ScheduleTransformer.self))
        )
    }
    
    override class func transformedValueClass() -> AnyClass {
        NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [Int] else { return nil }
        return try? JSONEncoder().encode(days)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([Int].self, from: data as Data)
    }
}
