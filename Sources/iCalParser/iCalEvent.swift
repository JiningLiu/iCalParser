//
//  iCalEvent.swift
//  
//
//  Created by Jining Liu on 4/15/23.
//

import Foundation

public struct iCalEvent {
    var dtStart: Date
    var dtEnd: Date
    var dtStamp: Date
    var uid: String
    var created: Date
    var description: String
    var lastModified: Date
    var location: String
    var sequence: Int
    var status: String
    var summary: String
    var transparency: String
}
