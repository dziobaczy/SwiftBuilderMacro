import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import BuilderMacroMacros

let testMacros: [String: Macro.Type] = [
    "Builder" : BuilderMacro.self,
    "ThrowingBuilder": ThrowingBuilderMacro.self
]

final class BuilderMacroTests: XCTestCase {
    func testBuilderMacro() {
        assertMacroExpansion("""
            @Builder
            struct User {
                let uuid: UUID
                let name: String
                let age: Int?
            }
            """,
            expandedSource: """

            struct User {
                let uuid: UUID
                let name: String
                let age: Int?

                public class Builder {
                    public var uuid: UUID?
                    public var name: String?
                    public var age: Int?
                    public init() {
                    }

                    public convenience init(_ item: User?) {
                        self.init()
                        fill(with: item)
                    }

                    public func fill(with item: User?) {
                        uuid = item?.uuid
                        name = item?.name
                        age = item?.age
                    }

                    public func build() -> User? {
                        guard let name else {
                            return nil
                        }
                        return User(
                        uuid: uuid ?? UUID(),
                        name: name,
                        age: age
                        )
                    }
                }

                public static func makeBuilder() -> Builder {
                    Builder()
                }
            }
            """,
            macros: testMacros
        )
    }
    
    func testThrowingBuilderMacro() {
        assertMacroExpansion("""
            @ThrowingBuilder
            struct User {
                let uuid: UUID
                let name: String
                let age: Int?
            }
            """,
            expandedSource: """

            struct User {
                let uuid: UUID
                let name: String
                let age: Int?

                public class Builder {
                    private enum Error: Swift.Error {
                        case missingValue(property: String)
                    }
                    public var uuid: UUID?
                    public var name: String?
                    public var age: Int?
                    public init() {
                    }

                    public convenience init(_ item: User?) {
                        self.init()
                        fill(with: item)
                    }

                    public func fill(with item: User?) {
                        uuid = item?.uuid
                        name = item?.name
                        age = item?.age
                    }

                    public func build() throws -> User {
                        guard let name else {
                            throw Error.missingValue(property: "name")
                        }
                        return User(
                        uuid: uuid ?? UUID(),
                        name: name,
                        age: age
                        )
                    }
                }

                public static func makeBuilder() -> Builder {
                    Builder()
                }
            }
            """,
            macros: testMacros
        )
    }
}
