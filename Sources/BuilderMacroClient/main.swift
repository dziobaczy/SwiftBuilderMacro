import BuilderMacro
import Foundation

// MARK: Example

@Builder
struct Breathing {
    let uuid: UUID
    let duration: Double
    let thoughts: String?
}

@ThrowingBuilder
struct Player {
    let uuid: UUID
    let coins: Int
    let hp: Int
}

@FluentBuilder
struct Quote {
    let uuid: UUID
    let text: String
    let author: String
}

let quote = Quote.makeBuilder()
    .text("What a time to be alive")
    .author("A dude")
    .build()

print(String(describing: quote))

let throwingBuilder = Player.makeBuilder()

do {
    throwingBuilder.coins = 100
    throwingBuilder.hp = 10
    let player = try throwingBuilder.build()
    print(player)
} catch {
    print(error)
}

let builder = Breathing.makeBuilder()
builder.duration = 60

print(String(describing: builder.build()))
