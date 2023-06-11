import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct BuilderMacro: MemberMacro {
    struct TypedVariable {
        let name: String
        let type: String
    }

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
        return []
    }
}

@main
struct BuilderMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        
    ]
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

extension BuilderMacro.TypedVariable {
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
