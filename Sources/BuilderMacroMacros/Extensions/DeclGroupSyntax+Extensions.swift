//
//  DeclGroupSyntax+Extensions.swift
//
//
//  Created by Piotr Szadkowski on 11/06/2023.
//

import SwiftSyntax

extension DeclGroupSyntax {
    /// Declaration name
    /// example: struct User will return "User"
    var name: String? {
        asProtocol(IdentifiedDeclSyntax.self)?.identifier.text
    }

    var storedVariables: [VariableDeclSyntax] {
        memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter(\.isStoredProperty)
    }

    var isStruct: Bool {
        self.as(StructDeclSyntax.self) != nil
    }
}
