//
//  iCalCalendar.swift
//  
//
//  Created by Jining Liu on 4/15/23.
//

import Foundation

public struct iCalCalendar {
    let prodID: String
    let version: String
    let calScale: String
    let method: String
    let name: String
    let timezone: String
    let events: [iCalEvent]
}

public extension iCalCalendar {
    init?(icsFileURL: URL) async {
        
        let icalUrlSchemeString = "webcal://calendar.google.com/calendar/ical/c_58vtu9jnpq7v03ooa6u0vdl7ec%40group.calendar.google.com/public/basic.ics"
        
        guard let icalUrl = URL(string: icalUrlSchemeString.replacingOccurrences(of: "webcal://", with: "https://")) else {
            return nil
        }
        
        guard let (data, _): (Data, URLResponse) = try? await {
           
            try await withCheckedThrowingContinuation { continuation in
                let task = URLSession.shared.dataTask(with: icalUrl) { data, response, error in
                    guard let data = data, let response = response else {
                        let error = error ?? URLError(.badServerResponse)
                        return continuation.resume(throwing: error)
                    }
                    
                    continuation.resume(returning: (data, response))
                }
                
                task.resume()
            }
            
        }() else {
            return nil
        }
        
        guard let icsString = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        let components = icsString.components(separatedBy: .newlines)
        var eventComponents: [String: String] = [:]
        var events: [iCalEvent] = []
        for component in components {
            if component.hasPrefix("BEGIN:VEVENT") {
                eventComponents = [:]
            } else if component.hasPrefix("END:VEVENT") {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
                guard let dtStart = dateFormatter.date(from: eventComponents["DTSTART"] ?? ""),
                      let dtEnd = dateFormatter.date(from: eventComponents["DTEND"] ?? ""),
                      let dtStamp = dateFormatter.date(from: eventComponents["DTSTAMP"] ?? ""),
                      let created = dateFormatter.date(from: eventComponents["CREATED"] ?? ""),
                      let lastModified = dateFormatter.date(from: eventComponents["LAST-MODIFIED"] ?? ""),
                      let sequence = Int(eventComponents["SEQUENCE"] ?? "") else {
                    continue
                }
                let uid = eventComponents["UID"] ?? ""
                let description = eventComponents["DESCRIPTION"] ?? ""
                let location = eventComponents["LOCATION"] ?? ""
                let status = eventComponents["STATUS"] ?? ""
                let summary = eventComponents["SUMMARY"] ?? ""
                let transparency = eventComponents["TRANSPARENCY"] ?? ""
                let event = iCalEvent(dtStart: dtStart,
                                      dtEnd: dtEnd,
                                      dtStamp: dtStamp,
                                      uid: uid,
                                      created: created,
                                      description: description,
                                      lastModified: lastModified,
                                      location: location,
                                      sequence: sequence,
                                      status: status,
                                      summary: summary,
                transparency: transparency)
                events.append(event)
            } else {
                let keyValuePair = component.components(separatedBy: ":")
                if keyValuePair.count == 2 {
                    eventComponents[keyValuePair[0]] = keyValuePair[1]
                }
            }
        }
        
        let calendarComponents: [String: String] = {
            
            var temp: [String: String] = [:]
            
            for i in components.split(separator: components.filter { $0.replacingOccurrences(of: " ", with: "").contains("BEGIN:VEVENT") }[0])[0].filter({ !$0.isEmpty }) {
                
                let split = i.split(separator: ":")
                var splitAfter = split
                splitAfter.removeFirst()
                temp[String(split[0])] = splitAfter.joined()
                
            }
            
            return temp
            
        }()
        
        guard let prodID = calendarComponents["PRODID"],
              let version = calendarComponents["VERSION"],
              let calScale = calendarComponents["CALSCALE"],
              let method = calendarComponents["METHOD"],
              let name = calendarComponents["X-WR-CALNAME"],
              let timezone = calendarComponents["X-WR-TIMEZONE"] else {
            return nil
        }
        
        self.prodID = prodID
        self.version = version
        self.calScale = calScale
        self.method = method
        self.name = name
        self.timezone = timezone
        self.events = events
    }
}

extension iCalEvent {
    init?(fromICSString icsString: String) {
        var dtStart: Date?
        var dtEnd: Date?
        var dtStamp: Date?
        var uid: String?
        var created: Date?
        var description: String?
        var lastModified: Date?
        var location: String?
        var sequence: Int?
        var status: String?
        var summary: String?
        var transparency: String?
        
        for line in icsString.components(separatedBy: .newlines) {
            let lineComponents = line.components(separatedBy: ":")
            if lineComponents.count != 2 {
                continue
            }
            let propertyName = lineComponents[0]
            let propertyValue = lineComponents[1]
            switch propertyName {
            case "DTSTART;VALUE=DATE":
                dtStart = iCalEvent.dateFromICSString(propertyValue)
            case "DTEND;VALUE=DATE":
                dtEnd = iCalEvent.dateFromICSString(propertyValue)
            case "DTSTAMP":
                dtStamp = iCalEvent.dateFromICSString(propertyValue)
            case "UID":
                uid = propertyValue
            case "CREATED":
                created = iCalEvent.dateFromICSString(propertyValue)
            case "DESCRIPTION":
                description = propertyValue
            case "LAST-MODIFIED":
                lastModified = iCalEvent.dateFromICSString(propertyValue)
            case "LOCATION":
                location = propertyValue
            case "SEQUENCE":
                sequence = Int(propertyValue)
            case "STATUS":
                status = propertyValue
            case "SUMMARY":
                summary = propertyValue
            case "TRANSP":
                transparency = propertyValue
            default:
                break
            }
        }
        
        guard let unwrappedDtStart = dtStart,
              let unwrappedDtEnd = dtEnd,
              let unwrappedDtStamp = dtStamp,
              let unwrappedUid = uid,
              let unwrappedCreated = created,
              let unwrappedDescription = description,
              let unwrappedLastModified = lastModified,
              let unwrappedLocation = location,
              let unwrappedSequence = sequence,
              let unwrappedStatus = status,
              let unwrappedSummary = summary,
              let unwrappedTransp = transparency else {
                  return nil
              }
        
        self.dtStart = unwrappedDtStart
        self.dtEnd = unwrappedDtEnd
        self.dtStamp = unwrappedDtStamp
        self.uid = unwrappedUid
        self.created = unwrappedCreated
        self.description = unwrappedDescription
        self.lastModified = unwrappedLastModified
        self.location = unwrappedLocation
        self.sequence = unwrappedSequence
        self.status = unwrappedStatus
        self.summary = unwrappedSummary
        self.transparency = unwrappedTransp
    }
    
    static func dateFromICSString(_ icsString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddTHHmmssZ"
        return dateFormatter.date(from: icsString)
    }
}
