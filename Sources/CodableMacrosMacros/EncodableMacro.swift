import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public enum EncodableMacro {}

// MARK: - MemberMacro

extension EncodableMacro: MemberMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let supported = declaration.is(StructDeclSyntax.self) || declaration.is(ClassDeclSyntax.self)
        
        guard supported else {
            // show unsupported declaration diagnostic message
            context.diagnose(Diagnostic(node: node, message: Message.unsupportedType))
            return []
        }
        
        // for struct the macro expands everything in the extension
        if declaration.is(StructDeclSyntax.self) {
            return []
        }
        
        // for class expands encode(to:) here
        if declaration.is(ClassDeclSyntax.self) {
            let modifiers = DecodableMacro.parseAccessModifiers(declaration.modifiers)
            let properties = declaration.memberBlock.members.filterStoredProperties()
            let encodeMethod = makeEncodableEncodeMethod(modifiers: modifiers, properties: properties)
            return [DeclSyntax(encodeMethod)]
        }
        
        // show unexpected use-case message
        context.diagnose(Diagnostic(node: node, message: Message.unexpected))
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
        let attributeNames = declaration.parseAttributeNames()
        let name = DecodableMacro.parseDeclarationName(declaration)
        let modifiers = DecodableMacro.parseAccessModifiers(declaration.modifiers)
        let properties = declaration.memberBlock.members.filterStoredProperties()
        
        let extensionInheritanceClause = InheritanceClauseSyntax(
            inheritedTypes: InheritedTypeListSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "Encodable"))
            }
        )
        
        let extensionMembers = MemberBlockItemListSyntax {
            if !attributeNames.contains("Decodable") && !properties.isEmpty {
                let enumCodingKeys = DecodableMacro.makeCodingKeys(modifiers: modifiers, properties: properties)
                MemberBlockItemSyntax(leadingTrivia: .newlines(2), decl: enumCodingKeys)
            }
            if declaration.is(StructDeclSyntax.self) && !properties.isEmpty {
                let encodeMethod = makeEncodableEncodeMethod(modifiers: modifiers, properties: properties)
                MemberBlockItemSyntax(leadingTrivia: .newlines(2), decl: encodeMethod)
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

// MARK: - Helper Methods

extension EncodableMacro {
    
    static func makeEncodableEncodeMethod(modifiers: DeclModifierListSyntax, properties: [VariableDeclSyntax]) -> FunctionDeclSyntax {
        FunctionDeclSyntax(
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
                    if !properties.isEmpty {
                        "var container = encoder.container(keyedBy: CodingKeys.self)"
                    }
                    for parameters in properties.compactMap({ $0.parseDecodableParameters() }) {
                        let name = parameters.name
                        "try container.encode(self.\(raw: name), forKey: .\(raw: name))"
                    }
                }
            )
        )
    }
}

// MARK: - Diagnostic

extension EncodableMacro {
    
    enum Message: String, DiagnosticMessage {
        
        case unsupportedType
        
        case unexpected
        
        var diagnosticID: MessageID {
            MessageID(domain: "CodableMacros", id: rawValue)
        }
    
        var severity: DiagnosticSeverity {
            switch self {
            case .unsupportedType: .error
            case .unexpected: .error
            }
        }
        
        var message: String {
            switch self {
            case .unsupportedType: "@Encodable only supports struct or class at this time"
            case .unexpected: "Encounter unexpected use case"
            }
        }
    }
}
