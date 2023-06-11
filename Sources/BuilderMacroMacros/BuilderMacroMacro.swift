import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct BuilderMacro: MemberMacro {
    enum Error: Swift.Error {
        case failedToFindSymbol(String)
        case wrongDeclarationSyntax
    }

    public static func expansion<
        Declaration: DeclGroupSyntax, Context: MacroExpansionContext
    >(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        guard declaration.isStruct else {
            throw Error.wrongDeclarationSyntax
        }
        guard let memberName = declaration.name else {
            throw Error.failedToFindSymbol("Missing Declaration Name")
        }

        let memberVariables = declaration.typedMembers

        return []
    }
}

@main
struct BuilderMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        
    ]
}

extension DeclGroupSyntax {
    fileprivate var typedMembers: [TypedVariable] {
        storedVariables.compactMap { property -> TypedVariable? in
            guard let name = property.name,
                  let type = property.typeString else {
                return nil
            }
            return TypedVariable(
                name: name,
                type: type
            )
        }
    }
}

extension BuilderMacro.Error: CustomStringConvertible {
    var description: String {
        switch self {
        case .failedToFindSymbol(let symbol):
            return "Couldn't find symbol: \(symbol)"
        case .wrongDeclarationSyntax:
            return "Builder Macro supports only structs"
        }
    }
}

private struct TypedVariable {
    let name: String
    let type: String
}

extension [TypedVariable] {
    var publicVariables: String {
        map(\.publicOptionalVarDefinition)
        .joined(separator: "\n")
    }

    var fillAssignments: String {
        map { $0.assignment(from: "item", isOptional: true) }
        .joined(separator: "\n")
    }

    var buildGuards: String {
        "guard " + self
            .filter { !$0.isOptional }
            .compactMap(\.guardCheck)
            .joined(separator: ", ")
    }

    var initAssignments: String {
        map(\.initAssignment)
        .joined(separator: ",\n")
    }
}

extension TypedVariable {
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

    var guardCheck: String? {
        return isUUID
        ? nil
        : "let \(name)"
    }

    var isUUID: Bool { name == "uuid" }
    var isOptional: Bool { type.last == "?" }

    private var optionalType: String {
        isOptional ? type : "\(type)?"
    }
}
