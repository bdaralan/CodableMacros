import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct CodableMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DecodableMacro.self,
        EncodableMacro.self,
        CodingKeyMacro.self
    ]
}
