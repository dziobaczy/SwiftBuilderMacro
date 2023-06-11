//
//  VariableDeclSyntax+Extensions.swift
//
//
//  Created by Piotr Szadkowski on 11/06/2023.
//

import SwiftSyntax

extension VariableDeclSyntax {
    /// variable name
    /// example var age: Int? will return age
    var name: String? {
        bindings.first?.pattern.as(
            IdentifierPatternSyntax.self
        )?.identifier.text
    }
    
    /// variable type
    /// example var name: String will return String
    var typeString: String? {
        typeSyntax?.description
    }
    /// variable type as Swift optional
    /// example var name: String will return String?
    var typeStringAsOptional: String? {
        guard let typeString else { return nil }
        return typeString.last == "?" ? typeString : "\(typeString)?"
    }

    private var typeSyntax: TypeSyntax? {
        bindings.first?.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type
    }

}

// SOURCE: https://github.com/DougGregor/swift-macro-examples
extension VariableDeclSyntax {
    /// Determine whether this variable has the syntax of a stored property.
    ///
    /// This syntactic check cannot account for semantic adjustments due to,
    /// e.g., accessor macros or property wrappers.
    var isStoredProperty: Bool {
        if bindings.count != 1 {
            return false
        }

        let binding = bindings.first!
        switch binding.accessor {
        case .none:
            return true

        case .accessors(let node):
            for accessor in node.accessors {
                switch accessor.accessorKind.tokenKind {
                case .keyword(.willSet), .keyword(.didSet):
                    // Observers can occur on a stored property.
                    break

                default:
                    // Other accessors make it a computed property.
                    return false
                }
            }

            return true

        case .getter:
            return false
        }
    }
}
