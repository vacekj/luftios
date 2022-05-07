//
//  LaunchViewModel.swift
//  Luftio
//
//  Created by Josef Vacek on 07.05.2022.
//

import Foundation

final class UserViewModel: ObservableObject {

    func fetch() {
        Network.shared.apollo.fetch(query: UserQuery()) { result in // Change the query name to your query name
          switch result {
          case .success(let graphQLResult):
            print("Success! Result: \(graphQLResult)")
          case .failure(let error):
            print("Failure! Error: \(error)")
          }
        }
    }

}
