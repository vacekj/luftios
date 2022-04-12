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
        let token = UserDefaults(suiteName: "group.vacekj")!.string(forKey: "web_token")
        urlRequest.addValue("Bearer \(token!)", forHTTPHeaderField: "X-Authorization")
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
            print("error parsing data from response")
            let response = LuftioAirQualityCallResponse.Failure
            completion?(response)
            return
        }
        
        let co2 = Int(apiresponse.co2.first!.value)!
        let timestamp = Date(timeIntervalSince1970: Double(apiresponse.co2.first!.ts / 1000))
        
        completion?(LuftioAirQualityCallResponse.Success(value: co2, timestamp: timestamp))
    }
}
