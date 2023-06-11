# Builder Macro

## Getting Started 🚀

While macros are still very fresh inspired by work done by Doug Gregor [here](https://github.com/DougGregor/swift-macro-examples) this repo aims to help get familliar with the macros by exploring their capabilities.

While the macros are still in "beta" since dependencies point to 5.9-DEVELOPMENT-SNAPSHOT you can probably add a Package library to your project if it will be created with Xcode 15 beta.

## Play around 🛝

For now to check it out download the repo and run executable target `BuilderMacroClient` the `BuilderMacro` contains most important code.

The basic concept of this macro is to generate a `Builder` helper class which will contain same stored properties as the struct that it's attached to, all optional to set them at need. Also a helper fill method to set all properties based on the filling object, and the build method which will attempt to generate the struct based on what's inside. Example of how it's influencing the code can be found inside `BuilderMacroTests`
