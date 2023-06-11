//
//  Diagnostics.swift
//
//
//  Created by Piotr Szadkowski on 11/06/2023.
//

import SwiftDiagnostics
import SwiftSyntax

enum Diagnostics {
    static func diagnose(
        declaration: DeclGroupSyntax
    ) -> SwiftDiagnostics.Diagnostic? {
        guard let tokens = attemptToStructConversion(from: declaration) else {
            return nil
        }

        return SwiftDiagnostics.Diagnostic(
            node: declaration.root,
            message: SimpleDiagnosticMessage(
                message: "@Builder only works on structs",
                diagnosticID: messageID,
                severity: .error
            ),
            fixIts: [
                FixIt(
                    message: SimpleDiagnosticMessage(
                        message: "replace with 'struct'",
                        diagnosticID: messageID,
                        severity: .error
                    ),
                    changes: [
                        FixIt.Change.replace(
                            oldNode: Syntax(tokens.old),
                            newNode: Syntax(tokens.new)
                        )
                    ]
                )
            ]
        )
    }

    private static func attemptToStructConversion(
        from declaration: DeclGroupSyntax
    ) -> (old: TokenSyntax, new: TokenSyntax)? {
        switch declaration {
        case let classDeclaration as ClassDeclSyntax:
            return (
                classDeclaration.classKeyword,
                classDeclaration.classKeyword.with(
                    \.tokenKind,
                     .identifier("struct")
                )
            )
        case let actorDeclaration as ActorDeclSyntax:
            return (
                actorDeclaration.actorKeyword,
                actorDeclaration.actorKeyword.with(
                    \.tokenKind,
                     .identifier("struct")
                )
            )
        default:
            return nil
        }
    }

    private static let messageID = MessageID(
        domain: "BuilderMacro",
        id: "WrongDeclarationKeyword"
    )
}

// SOURCE: https://github.com/DougGregor/swift-macro-examples
struct SimpleDiagnosticMessage: DiagnosticMessage, Error {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity
}

extension SimpleDiagnosticMessage: FixItMessage {
    var fixItID: MessageID { diagnosticID }
}

enum CustomError: Error, CustomStringConvertible {
    case message(String)

    var description: String {
        switch self {
        case .message(let text):
            return text
        }
    }
}
