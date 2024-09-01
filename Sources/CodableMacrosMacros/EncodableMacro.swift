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
        let attributeNames = declaration.parseAttributeNames()
        
        // cannot use Decodable and Encodable together
        // DecodableMacro will be the one to emit the diagnostic message
        if attributeNames.contains("Decodable") && attributeNames.contains("Encodable") {
            return []
        }
        
        // for struct and class the macro expands everything in the extension
        if declaration.is(StructDeclSyntax.self) || declaration.is(ClassDeclSyntax.self) {
            return []
        }
        
        // show unsupported declaration diagnostic message
        context.diagnose(Diagnostic(node: node, message: Message.unsupportedType))
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
        
        // cannot use Decodable and Encodable together
        if attributeNames.contains("Decodable") && attributeNames.contains("Encodable") {
            return []
        }
        
        let name = DecodableMacro.parseDeclarationName(declaration)
        let modifiers = DecodableMacro.parseAccessModifiers(declaration.modifiers)
        let properties = declaration.memberBlock.members.filterStoredProperties()
        
        let enumCodingKeys = DecodableMacro.makeCodingKeys(modifiers: modifiers, properties: properties)
        let encodeMethod = makeEncodableEncodeMethod(modifiers: modifiers, properties: properties)
        
        let extensionInheritanceClause = InheritanceClauseSyntax(
            inheritedTypes: InheritedTypeListSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "Encodable"))
            }
        )
        
        let extensionMembers = MemberBlockItemListSyntax {
            MemberBlockItemSyntax(leadingTrivia: .newlines(2), decl: enumCodingKeys)
            MemberBlockItemSyntax(leadingTrivia: .newlines(2), decl: encodeMethod)
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
