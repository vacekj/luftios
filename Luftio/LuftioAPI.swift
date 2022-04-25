//
//  LuftioAPI.swift
//  Luftio
//
//  Created by Josef Vacek on 12.04.2022.
//

import Foundation

enum LuftioAirQualityCallResponse {
    case Success(value: Int, timestamp: Date)
    case Failure
}

enum LuftioAirQualityTimeseries {
    case Success(values: Response)
    case Failure
}

struct Response: Codable {
    let co2, tvoc: [Co2]
}

struct Co2: Codable {
    let ts: Int
    let value: String
}

enum LuftioApiError: Error {
    case tokenNotFound
}

class LuftioAirQualityProvider {
    static func getValueFromApi( completion: ((LuftioAirQualityCallResponse) -> Void)?) {
        let device_id = "d227a410-2c28-11ec-af15-5fd753da8a14"
        let urlString = "https://app.luftio.com/tb/api/plugins/telemetry/DEVICE/\(device_id)/values/timeseries?keys=co2,tvoc"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        let token = UserDefaults(suiteName: "group.vacekj")!.string(forKey: "web_token")
        if (token == nil) {
            return;
        }
        urlRequest.addValue("Bearer \(token!)", forHTTPHeaderField: "X-Authorization")
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            parseResponseAndGetValue(data: data, urlResponse: urlResponse, error: error, completion: completion)
        }
        task.resume()
    }
    
    static func getTimeSeriesFromApi(from: Date, to: Date, completion: ((LuftioAirQualityTimeseries) -> Void)?) throws {
        let to_ms = Int(to.timeIntervalSince1970 * 1000);
        let device_id = "d227a410-2c28-11ec-af15-5fd753da8a14"
        let urlString = "https://app.luftio.com/tb/api/plugins/telemetry/DEVICE/\(device_id)/values/timeseries?keys=co2,tvoc&startTs=0&endTs=\(to_ms)&limit=100"
        
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        let token = UserDefaults(suiteName: "group.vacekj")!.string(forKey: "web_token")
        if token == nil {
            throw LuftioApiError.tokenNotFound
        }
        urlRequest.addValue("Bearer \(token!)", forHTTPHeaderField: "X-Authorization")
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            parseResponseAndGetTimeseriesData(data: data, urlResponse: urlResponse, error: error, completion: completion)
        }
        task.resume()
    }
    
    static func parseResponseAndGetTimeseriesData(data: Data?, urlResponse: URLResponse?, error: Error?, completion: ((LuftioAirQualityTimeseries) -> Void)?) {
        guard error == nil, let content = data else {
            print("error getting data from API")
            let response = LuftioAirQualityTimeseries.Failure
            completion?(response)
            return
        }
        
        var apiresponse: Response
        do {
            apiresponse = try JSONDecoder().decode(Response.self, from: content)
        } catch {
            print(error)
            print("error parsing data from response")
            let response = LuftioAirQualityTimeseries.Failure
            completion?(response)
            return
        }
        
        completion?(LuftioAirQualityTimeseries.Success(values: apiresponse))
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
