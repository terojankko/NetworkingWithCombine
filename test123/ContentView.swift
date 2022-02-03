//
//  ContentView.swift
//  test123
//
//  Created by Tero on 1/20/21.
//

import SwiftUI
import Combine
import Network


class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")
    
    var isActive = false
    var isExpensive = false
    var isConstrained = false
    var connectionType = NWInterface.InterfaceType.other
    
    init() {
        monitor.pathUpdateHandler = { path in
            
                print(path.status)
            self.isActive = path.status == .satisfied
            self.isExpensive = path.isExpensive
            self.isConstrained = path.isConstrained
            
            let connectionTypes: [NWInterface.InterfaceType] = [.cellular, .wifi, .wiredEthernet]
            self.connectionType = connectionTypes.first(where: path.usesInterfaceType) ?? .other
            print(connectionTypes.first(where: path.usesInterfaceType) ?? .other)
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
            
        }
        monitor.start(queue: queue)
    }
}


struct ContentView: View {
    
    @EnvironmentObject var network: NetworkMonitor
    @State private var requests = Set<AnyCancellable>()
    
    var body: some View {
        
        VStack {
            Text(verbatim: """
            Active: \(network.isActive)
            Expensive: \(network.isExpensive)
            Constrained: \(network.isConstrained)
            """)
                .padding()
        
            Button("Fetch data") {
                
                
                
                let url = URL(string: "https://www.hackingwithswift.com/samples/user-24601.json")!
                self.fetch(url, defaultValue: User.default) { response in
                    print(response.name)
                }
            }
        }
        .padding()
    }
    
//    func fetch(_ url: URL) {
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                print("error: ", error.localizedDescription)
//            } else if let data = data {
//                let decoder = JSONDecoder()
//                do {
//                    let user = try decoder.decode(User.self, from: data)
//                    print(user.name)
//                } catch {
//                    print("error decoding data", error.localizedDescription)
//                }
//            }
//        }.resume()
//    }

    
    func fetch<T: Decodable>(_ url: URL, defaultValue: T, completion: @escaping (T) -> Void) {
        let decoder = JSONDecoder()
        
        let config = URLSessionConfiguration.default
        config.allowsExpensiveNetworkAccess = false
        config.allowsConstrainedNetworkAccess = false
        config.waitsForConnectivity = true
        //config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let session = URLSession(configuration: config)
        session.dataTaskPublisher(for: url)
            .retry(1)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .replaceError(with: defaultValue)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: completion)
            .store(in: &requests)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
