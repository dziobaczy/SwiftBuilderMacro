import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct BuilderMacro: MemberMacro {
    struct TypedVariable {
        let name: String
        let type: String
    }

    public static func expansion<
        Declaration: DeclGroupSyntax, Context: MacroExpansionContext
    >(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        []
    }
}

@main
struct BuilderMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        
    ]
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
