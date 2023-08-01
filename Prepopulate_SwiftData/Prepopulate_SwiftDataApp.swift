//
//  Prepopulate_SwiftDataApp.swift
//  Example of initialising SwiftData with a JSON string
//
//  Created by andrew on 2/8/2023.
//
//  Requires Xcode 15.5, and iOS 17.0

import SwiftUI
import SwiftData

// MARK: - Trip.swift

@Model final class Trip : Codable, CustomStringConvertible {
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    
    init(name: String, destination: String, startDate: Date, endDate: Date) {
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.name = name
    }

    // MARK: Date <-> String...
    
    private static var dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter
        }()
    
    private func date(from:String) -> Date {
        return Trip.dateFormatter.date(from: from)!  // assumes a valid date string
    }
    private func date(from:Date) -> String {
        return Trip.dateFormatter.string(from: from)
    }

    
    // MARK: Codable methods, to make convertable from JSON...
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.destination = try container.decode(String.self, forKey: .destination)
        let startDateString = try container.decode(String.self, forKey: .startDate)
        self.startDate = date(from: startDateString)
        let endDateString = try container.decode(String.self, forKey: .endDate)
        self.endDate = date(from: endDateString)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.destination, forKey: .destination)
        try container.encode(self.startDate, forKey: .startDate)
        try container.encode(self.endDate, forKey: .endDate)
    }

    // allow access the properties of the Trip class by their names in JSON
    enum CodingKeys: String, CodingKey {
        case name
        case startDate
        case destination
        case endDate
    }
    
    // MARK: CustomStringConvertible method, to make class printable...
    var description: String {
        return "Trip(name: \(name), destination: \(destination), startDate: \(date(from: startDate)), endDate: \(date(from: endDate)))"
    }
}

// MARK: - App.swift

@main
struct Prepopulate_SwiftDataApp: App {
    init() {
        
        let jsonData = """
{
    "destination": "Paris",
    "endDate": "2023-08-15",
    "name": "My Trip to Paris",
    "startDate": "2023-08-01"
}

""".data(using: .utf8)!
        
        do {
            let container = try ModelContainer(for: Trip.self)

            let newTrip = try JSONDecoder().decode(Trip.self, from: jsonData)
            
            container.mainContext.insert(newTrip)

            print(newTrip)
        } catch {
            print("Unexpected error: \(error).")
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

