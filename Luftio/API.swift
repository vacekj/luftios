// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class UserQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query User {
      devices {
        __typename
        id
        color
        data {
          __typename
          values {
            __typename
            value
            ts
          }
        }
        label
        title
      }
    }
    """

  public let operationName: String = "User"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("devices", type: .nonNull(.list(.nonNull(.object(Device.selections))))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(devices: [Device]) {
      self.init(unsafeResultMap: ["__typename": "Query", "devices": devices.map { (value: Device) -> ResultMap in value.resultMap }])
    }

    public var devices: [Device] {
      get {
        return (resultMap["devices"] as! [ResultMap]).map { (value: ResultMap) -> Device in Device(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: Device) -> ResultMap in value.resultMap }, forKey: "devices")
      }
    }

    public struct Device: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Device"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("color", type: .nonNull(.scalar(String.self))),
          GraphQLField("data", type: .list(.nonNull(.object(Datum.selections)))),
          GraphQLField("label", type: .nonNull(.scalar(String.self))),
          GraphQLField("title", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, color: String, data: [Datum]? = nil, label: String, title: String) {
        self.init(unsafeResultMap: ["__typename": "Device", "id": id, "color": color, "data": data.flatMap { (value: [Datum]) -> [ResultMap] in value.map { (value: Datum) -> ResultMap in value.resultMap } }, "label": label, "title": title])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var color: String {
        get {
          return resultMap["color"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "color")
        }
      }

      public var data: [Datum]? {
        get {
          return (resultMap["data"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Datum] in value.map { (value: ResultMap) -> Datum in Datum(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Datum]) -> [ResultMap] in value.map { (value: Datum) -> ResultMap in value.resultMap } }, forKey: "data")
        }
      }

      public var label: String {
        get {
          return resultMap["label"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "label")
        }
      }

      public var title: String {
        get {
          return resultMap["title"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "title")
        }
      }

      public struct Datum: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["DeviceData"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("values", type: .nonNull(.list(.nonNull(.object(Value.selections))))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(values: [Value]) {
          self.init(unsafeResultMap: ["__typename": "DeviceData", "values": values.map { (value: Value) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var values: [Value] {
          get {
            return (resultMap["values"] as! [ResultMap]).map { (value: ResultMap) -> Value in Value(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: Value) -> ResultMap in value.resultMap }, forKey: "values")
          }
        }

        public struct Value: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["DeviceDataValue"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("value", type: .nonNull(.scalar(Double.self))),
              GraphQLField("ts", type: .nonNull(.scalar(String.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(value: Double, ts: String) {
            self.init(unsafeResultMap: ["__typename": "DeviceDataValue", "value": value, "ts": ts])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var value: Double {
            get {
              return resultMap["value"]! as! Double
            }
            set {
              resultMap.updateValue(newValue, forKey: "value")
            }
          }

          public var ts: String {
            get {
              return resultMap["ts"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "ts")
            }
          }
        }
      }
    }
  }
}
