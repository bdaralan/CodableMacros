import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public enum EncodableMacro {
    
    enum Message: String, DiagnosticMessage {
        
        case unsupportedType
        
        var diagnosticID: MessageID {
            MessageID(domain: "CodableMacros", id: rawValue)
        }
    
        var severity: DiagnosticSeverity {
            switch self {
            case .unsupportedType: .error
            }
        }
        
        var message: String {
            switch self {
            case .unsupportedType: "@Encodable only supports struct or class at this time"
            }
        }
    }
}

// MARK: - MemberMacro

extension EncodableMacro: MemberMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // for struct the macro expands everything in the extension
        if declaration.is(StructDeclSyntax.self) {
            return []
        }
        return []
    }
}

// MARK: - ExtensionMacro

extension EncodableMacro: ExtensionMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let name = DecodableMacro.parseDeclarationName(declaration)
        let modifiers = DecodableMacro.parseAccessModifiers(declaration.modifiers)
        let properties = declaration.memberBlock.members.filterStoredProperties()
        
        let enumCodingKeys = DecodableMacro.makeCodingKeys(modifiers: modifiers, properties: properties)
        
        let extensionInheritanceClause = InheritanceClauseSyntax(
            inheritedTypes: InheritedTypeListSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "Encodable"))
            }
        )
        
        let extensionMembers = MemberBlockItemListSyntax {
            MemberBlockItemSyntax(leadingTrivia: .newlines(2), decl: enumCodingKeys)
            if declaration.is(StructDeclSyntax.self) {
                let encodableEncodeMethod = makeEncodableEncodeMethod(modifiers: modifiers, properties: properties)
                MemberBlockItemSyntax(leadingTrivia: .newlines(2), decl: encodableEncodeMethod)
            }
        }
        
        let extensionDecl = ExtensionDeclSyntax(
            extendedType: IdentifierTypeSyntax(name: .identifier(name)),
            inheritanceClause: extensionInheritanceClause,
            memberBlock: MemberBlockSyntax(members: extensionMembers)
        )
        
        return [extensionDecl]
    }
}

// MARK: - Helpers

extension EncodableMacro {
    
    static func makeEncodableEncodeMethod(modifiers: DeclModifierListSyntax, properties: [VariableDeclSyntax]) -> FunctionDeclSyntax {
        FunctionDeclSyntax(
            attributes: AttributeListSyntax(),
            modifiers: modifiers,
            funcKeyword: .keyword(.func),
            name: TokenSyntax("encode"),
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: FunctionParameterListSyntax {
                        FunctionParameterSyntax(
                            firstName: "to",
                            secondName: "encoder",
                            type: SomeOrAnyTypeSyntax(
                                someOrAnySpecifier: .keyword(.any),
                                constraint: IdentifierTypeSyntax(name: "Encoder")
                            )
                        )
                    }
                ),
                effectSpecifiers: FunctionEffectSpecifiersSyntax(throwsSpecifier: .keyword(.throws))
            ),
            body: CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    "var container = encoder.container(keyedBy: CodingKeys.self)"
                    for parameters in properties.compactMap({ $0.parseDecodableParameters() }) {
                        let name = parameters.name
                        "try container.encode(\(raw: name), forKey: .\(raw: name))"
                    }
                }
            )
        )
    }
}
