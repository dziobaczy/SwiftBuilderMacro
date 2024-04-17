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
        asProtocol(NamedDeclSyntax.self)?.name.text
    }

    var storedVariables: [VariableDeclSyntax] {
        memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter(\.isStoredProperty)
    }

    var initializer: InitializerDeclSyntax? {
        memberBlock.members.first(
            where: { $0.decl.is(InitializerDeclSyntax.self) }
        )?.decl.as(InitializerDeclSyntax.self)
    }

    var isStruct: Bool {
        self.as(StructDeclSyntax.self) != nil
    }
}
