//
//  Util.swift
//  SGNewsReader
//
//  Created by Gabor Sornyei on 2022. 03. 19..
//

import Foundation

struct Util {
    static func buildDateFromString(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en")
        formatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        let dt = formatter.date(from: string)
        
        if dt == nil {
            let formatter = ISO8601DateFormatter()
            return formatter.date(from: string)
        } else {
            return dt
        }

    }

}
