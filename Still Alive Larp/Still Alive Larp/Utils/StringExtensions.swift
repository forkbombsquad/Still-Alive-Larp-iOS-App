//
//  StringExtensions.swift
//  Still Alive Larp
//
//  Created by Rydge Craker on 11/11/22.
//

import Foundation
import SwiftUI

extension String {
    
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
    
    var jsonData: Data? {
        return self.data(using: .utf8)
    }

    var boolValue: Bool? {
        return Bool(self.lowercased())
    }

    var boolValueDefaultFalse: Bool {
        return self.boolValue ?? false
    }

    var intValue: Int? {
        return Int(self)
    }

    var intValueDefaultZero: Int {
        return self.intValue ?? 0
    }

    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func toTextView() -> Text {
        return Text(self)
    }

    func splitToStringArray(_ separator: String) -> [String] {
        let array = self.components(separatedBy: separator)
        var strArray = [String]()
        for str in array {
            strArray.append(String(str))
        }
        return strArray
    }
    
    func countOccurances(_ substring: String) -> Int {
        return self.splitToStringArray(substring).count - 1
    }

    func yyyyMMddtoDate() -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.date(from: self) ?? Date()
    }

    func yyyyMMddToMonthDayYear() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy/MM/dd"
        guard let date = formatter.date(from: self) else {
            return self
        }
        let dateComponents = Calendar.current.component(.day, from: date)
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .ordinal
        let day = numFormatter.string(from: dateComponents as NSNumber)
        formatter.dateFormat = "MMMM"
        var dateString = "\(formatter.string(from: date)) \(day ?? "?"), "
        formatter.dateFormat = "yyyy"
        dateString += formatter.string(from: date)
        return dateString
    }

    func containsIgnoreCase(_ text: String) -> Bool {
        return self.lowercased().contains(text.lowercased())
    }
    
    func equalsIgnoreCase(_ text: String) -> Bool {
        return self.lowercased() == text.lowercased()
    }

    func compress() -> Data? {
        guard let data = self.data(using: .utf8), let compressed = try? data.gzipped() else {
            return nil
        }
        let base64String = compressed.base64EncodedString()
        return base64String.data(using: .utf8)
    }
    
    func decompress() -> Data? {
        guard let gzippedData = Data(base64Encoded: self),
              let decompressedData = try? gzippedData.gunzipped() else {
            return nil
        }
        return decompressedData
    }
    
}
