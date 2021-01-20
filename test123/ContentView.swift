//
//  ContentView.swift
//  test123
//
//  Created by Tero on 1/20/21.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @State private var requests = Set<AnyCancellable>()
    
    var body: some View {
        Button("Fetch data") {
            let url = URL(string: "https://www.hackingwithswift.com/samples/user-24601.json")!
            self.fetch(url, defaultValue: User.default) { response in
                print(response.name)
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
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .replaceError(with: defaultValue)
            .sink(receiveValue: completion)
            .store(in: &requests)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
