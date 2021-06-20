//
//  String.swift
//  RSSFeeder
//
//  Created by Dino Franic on 20.06.2021..
//

import Foundation

extension String
{
    func toDate(formatter: String = "YYYY-MM-dd HH:mm:ss Z") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        
        return dateFormatter.date(from: self)
    }
}
