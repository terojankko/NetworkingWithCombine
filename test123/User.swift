//
//  User.swift
//  test123
//
//  Created by Tero on 1/20/21.
//

import Foundation

struct User: Decodable {
    var id: UUID
    var name: String
    static let `default` = User(id: UUID(), name: "Anonymous")
}
