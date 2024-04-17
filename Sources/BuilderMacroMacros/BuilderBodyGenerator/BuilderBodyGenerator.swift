//
//  BuilderBodyGenerator.swift
//  
//
//  Created by Piotr Szadkowski on 05/08/2023.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension BuilderBodyGenerator.Configuration {
    static let throwing = Self(isThrowing: true)
}

struct BuilderBodyGenerator {
    fileprivate enum Error: Swift.Error {
        case missingDeclarationName
    }
    
    fileprivate struct TypedVariable {
        let name: String
        let type: String
        let hasDefaultValue: Bool
    }
    
    struct Configuration {
        let isThrowing: Bool
        
        init(isThrowing: Bool = false) { self.isThrowing = isThrowing }
    }
    
    private let configuration: Configuration

    init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }
    
    func generateBody(from declaration: DeclGroupSyntax) throws -> [DeclSyntax] {
        guard let memberName = declaration.name else {
            throw Error.missingDeclarationName
        }

        var paramsWithDefaultValue = [String]()
        if let initializer = declaration.initializer {
            for parameter in initializer.signature.parameterClause.parameters {
                if parameter.defaultValue != nil {
                    paramsWithDefaultValue.append(parameter.firstName.trimmed.text)
                }
            }
        }

        if configuration.isThrowing {
            return generateThrowingBody(
                memberName: memberName,
                vars: declaration.typedMembers(paramsWithDefaultValue: paramsWithDefaultValue)
            )
        } else {
            return generateBody(
                memberName: memberName,
                vars: declaration.typedMembers(paramsWithDefaultValue: paramsWithDefaultValue)
            )
        }
    }
}

// MARK: Body Generation
extension BuilderBodyGenerator {
    fileprivate func generateBody(
        memberName: String,
        vars: [TypedVariable]
    ) -> [DeclSyntax] {
        ["""
        public class Builder {
        \(raw: vars.publicVariables)
        public init() {
        }

        \(raw: convenienceInitDecl(memberName: memberName))

        public func fill(with item: \(raw: memberName)?) {
            \(raw: vars.fillAssignments)
        }

        public func build() -> \(raw: memberName)? {
            \(raw: vars.buildGuards)
            return \(raw: memberName)(
            \(raw: vars.initAssignments)
            )
        }
        }

        \(raw: makeBuilderDecl())
        """
        ]
    }
    
    fileprivate func generateThrowingBody(
        memberName: String,
        vars: [TypedVariable]
    ) -> [DeclSyntax] {
        ["""
        public class Builder {
        private enum Error: Swift.Error {
            case missingValue(property: String)
        }
        \(raw: vars.publicVariables)
        public init() {
        }

        \(raw: convenienceInitDecl(memberName: memberName))

        public func fill(with item: \(raw: memberName)?) {
            \(raw: vars.fillAssignments)
        }

        public func build() throws -> \(raw: memberName) {
            \(raw: vars.throwingBuildGuards)
            return \(raw: memberName)(
            \(raw: vars.initAssignments)
            )
        }
        }

        \(raw: makeBuilderDecl())
        """
        ]
    }
    
    private func convenienceInitDecl(memberName: String) -> String {
        """
        public convenience init(_ item: \(memberName)?) {
            self.init()
            fill(with: item)
        }
        """
    }
    
    private func makeBuilderDecl() -> String {
        """
        public static func makeBuilder() -> Builder {
            Builder()
        }
        """
    }
}

// MARK: Body Fields Construction
extension [BuilderBodyGenerator.TypedVariable] {
    var publicVariables: String {
        map(\.publicOptionalVarDefinition)
        .joined(separator: "\n")
    }

    var fillAssignments: String {
        map { $0.assignment(from: "item", isOptional: true) }
        .joined(separator: "\n")
    }
    
    fileprivate var variablesToGuard: [BuilderBodyGenerator.TypedVariable] {
        filter { !$0.isOptional && !$0.hasDefaultValue && !$0.isUUID }
    }

    var throwingBuildGuards: String {
        if variablesToGuard.isEmpty {
            return ""
        }
        return variablesToGuard
            .map(\.throwingGuardCheck)
            .joined()
    }

    var buildGuards: String {
        if variablesToGuard.isEmpty {
            return ""
        }
        return "guard " + variablesToGuard
            .map(\.guardCheck)
            .joined(separator: ", ")
        + " else { return nil }"
    }

    var initAssignments: String {
        map(\.initAssignment)
        .joined(separator: ",\n")
    }
}

extension BuilderBodyGenerator.TypedVariable {
    func assignment(
        from property: String,
        isOptional: Bool
    ) -> String {
        "\(name) = \(property + (isOptional ? "?" : "")).\(name)"
    }

    var initAssignment: String {
        isUUID
        ? "\(name): \(name) ?? UUID()"
        : "\(name): \(name)"
    }

    var publicOptionalVarDefinition: String {
        "public var \(name): \(optionalType)"
    }
    
    var throwingGuardCheck: String {
        return "guard let \(name) else { throw Error.missingValue(property: \"\(name)\") }"
    }

    var guardCheck: String {
        return "let \(name)"
    }

    var isUUID: Bool { name == "uuid" }
    var isOptional: Bool { type.last == "?" }

    private var optionalType: String {
        isOptional ? type : "\(type)?"
    }
}

extension DeclGroupSyntax {
    /// Produces convenience structs from stored properties
    /// with name and type accessible as strings
    fileprivate func typedMembers(paramsWithDefaultValue: [String]) -> [BuilderBodyGenerator.TypedVariable] {
        storedVariables.compactMap { property -> BuilderBodyGenerator.TypedVariable? in
            guard let name = property.name,
                  let type = property.typeString else {
                return nil
            }
            return BuilderBodyGenerator.TypedVariable(
                name: name,
                type: type,
                hasDefaultValue: paramsWithDefaultValue.contains(name)
            )
        }
    }
}

extension BuilderBodyGenerator.Error: CustomStringConvertible {
    var description: String {
        switch self {
        case .missingDeclarationName:
            return "Unable not find declaration name for type"
        }
    }
}
