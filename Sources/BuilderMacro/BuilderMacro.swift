/// A macro that produces Builder
@attached(member, names: arbitrary)
public macro Builder() = #externalMacro(
    module: "BuilderMacroMacros",
    type: "BuilderMacro"
)
