import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct CodableMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CodableMacro.self,
        DecodableMacro.self,
        EncodableMacro.self,
        CodingKeyMacro.self
    ]
}
