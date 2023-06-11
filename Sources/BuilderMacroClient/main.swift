import BuilderMacro
import Foundation

// MARK: Example

@Builder
struct Breathing {
    let uuid: UUID
    let duration: Double
    let thoughts: String?
}

let builder = Breathing.makeBuilder()
builder.duration = 60

print(String(describing: builder.build()))
