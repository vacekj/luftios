//
//  File.swift
//  Luftio
//
//  Created by Josef Vacek on 07.05.2022.
//

import Foundation
import Apollo

class Network {
  static let shared = Network()
  
    private(set) lazy var apollo: ApolloClient = {
        let client = URLSessionClient()
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)
        let provider = NetworkInterceptorProvider(client: client, store: store)
        let url = URL(string: "https://app.luftio.com/backend/graphql")!
        let transport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                     endpointURL: url)
        return ApolloClient(networkTransport: transport, store: store)
    }()
}

class NetworkInterceptorProvider: DefaultInterceptorProvider {
    override func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(TokenAddingInterceptor(), at: 0)
        return interceptors
    }
}

class TokenAddingInterceptor: ApolloInterceptor {
    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) {

            
            if let token = UserDefaults(suiteName: "group.vacekj")!.string(forKey: "web_token") {
                request.addHeader(name: "X-Authorization", value: "Bearer \(token)")
            } // else do nothing

            chain.proceedAsync(request: request,
                               response: response,
                               completion: completion)
    }
}
