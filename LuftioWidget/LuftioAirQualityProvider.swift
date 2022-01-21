//
//  ApodImageProvider.swift
//  ApodWidgetExtension
//
//  Created by SchwiftyUI on 12/7/20.
//

import Foundation
import SwiftUI

enum LuftioAirQualityCallResponse {
    case Success(value: Int, timestamp: Date)
    case Failure
}

struct Response: Codable {
    let co2, tvoc: [Co2]
}

struct Co2: Codable {
    let ts: Int
    let value: String
}

class LuftioAirQualityProvider {
    static func getValueFromApi(completion: ((LuftioAirQualityCallResponse) -> Void)?) {
        let device_id = "d227a410-2c28-11ec-af15-5fd753da8a14"
        let urlString = "https://app.luftio.com/tb/api/plugins/telemetry/DEVICE/\(device_id)/values/timeseries?keys=co2,tvoc"
        
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ2YWNla2pAb3V0bG9vay5jb20iLCJzY29wZXMiOlsiQ1VTVE9NRVJfVVNFUiJdLCJ1c2VySWQiOiIxZjE3ZmRhMC00MmU2LTExZWMtYWYxNS01ZmQ3NTNkYThhMTQiLCJmaXJzdE5hbWUiOiJKb3NlZiIsImxhc3ROYW1lIjoiVmFjZWsiLCJlbmFibGVkIjp0cnVlLCJpc1B1YmxpYyI6ZmFsc2UsInRlbmFudElkIjoiNTFiNzRlNDAtMzI2Ny0xMWViLWJjZmUtMjcwZWU5NDE0ZjFhIiwiY3VzdG9tZXJJZCI6IjE2OTA0ZTMwLTQyZTYtMTFlYy1hZjE1LTVmZDc1M2RhOGExNCIsImlzcyI6InRoaW5nc2JvYXJkLmlvIiwiaWF0IjoxNjQyNTkzNTQ2LCJleHAiOjE2NDc0MzE5NDZ9.Ea8-mwMH0oHNUEDBGdQptDdTwWxGK-ljMfXr7UTlRU1pkbmLTlL1d0Kx3qATnKQzqJxbx2j0jO7qWkKrW2ZQqA", forHTTPHeaderField: "X-Authorization")
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            parseResponseAndGetValue(data: data, urlResponse: urlResponse, error: error, completion: completion)
        }
        task.resume()
    }
    
    static func parseResponseAndGetValue(data: Data?, urlResponse: URLResponse?, error: Error?, completion: ((LuftioAirQualityCallResponse) -> Void)?) {
        guard error == nil, let content = data else {
            print("error getting data from API")
            let response = LuftioAirQualityCallResponse.Failure
            completion?(response)
            return
        }
        
        var apiresponse: Response
        do {
            apiresponse = try JSONDecoder().decode(Response.self, from: content)
        } catch {
            print(error)
            print("error parsing URL from data")
            let response = LuftioAirQualityCallResponse.Failure
            completion?(response)
            return
        }
        
        let co2 = Int(apiresponse.co2.first!.value)!
        let timestamp = Date(timeIntervalSince1970: Double(apiresponse.co2.first!.ts / 1000))
        
        completion?(LuftioAirQualityCallResponse.Success(value: co2, timestamp: timestamp))
    }
}
