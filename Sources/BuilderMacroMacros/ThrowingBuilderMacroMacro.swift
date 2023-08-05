import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ThrowingBuilderMacro: MemberMacro {
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
            guard let diagnostic = Diagnostics.diagnose(declaration: declaration) else {
                throw Error.wrongDeclarationSyntax
            }

            context.diagnose(diagnostic)
            return []
        }

        let bodyGenerator = BuilderBodyGenerator(configuration: .throwing)
        return try bodyGenerator.generateBody(from: declaration)
    }
}
