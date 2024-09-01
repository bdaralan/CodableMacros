import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public enum DecodableMacro {}

// MARK: - MemberMacro

extension DecodableMacro: MemberMacro {
    
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
        
        // for class the macro expands the constructor in the class declaration
        // then expands everything else in the extension
        if declaration.is(ClassDeclSyntax.self) {
            var modifiers = parseAccessModifiers(declaration.modifiers)
            if !declaration.modifiers.contains(where: { $0.name.text == "final" }) {
                modifiers.append(DeclModifierSyntax(name: .keyword(.required)))
            }
            let properties = declaration.memberBlock.members.filterStoredProperties()
            let decodableConstructor = makeDecodableConstructor(modifiers: modifiers, properties: properties)
            return [DeclSyntax(decodableConstructor)]
        }
        
        // show unsupported declaration diagnostic message
        context.diagnose(Diagnostic(node: node, message: Message.unsupportedType))
        return []
    }
}

// MARK: - ExtensionMacro

extension DecodableMacro: ExtensionMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let name = parseDeclarationName(declaration)
        let modifiers = parseAccessModifiers(declaration.modifiers)
        let properties = declaration.memberBlock.members.filterStoredProperties()
        let enumCodingKeys = makeCodingKeys(modifiers: modifiers, properties: properties)
        let extensionInheritanceClause = InheritanceClauseSyntax(
            inheritedTypes: InheritedTypeListSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "Decodable"))
            }
        )
        
        let extensionMembers = MemberBlockItemListSyntax {
            MemberBlockItemSyntax(leadingTrivia: .newlines(2), decl: enumCodingKeys)
            if declaration.is(StructDeclSyntax.self) {
                let decodableConstructor = makeDecodableConstructor(modifiers: modifiers, properties: properties)
                MemberBlockItemSyntax(leadingTrivia: .newlines(2), decl: decodableConstructor)
            }
        }
        
        let extensionDecl = ExtensionDeclSyntax(
            extendedType: IdentifierTypeSyntax(name: .identifier(name)),
            inheritanceClause: extensionInheritanceClause,
            memberBlock: MemberBlockSyntax(
                members: extensionMembers
            )
        )
        
        return [extensionDecl]
    }
}

// MARK: - Helper Methods

extension DecodableMacro {
    
    static func parseDeclarationName(_ decl: DeclGroupSyntax) -> String {
        switch decl {
        case let decl as EnumDeclSyntax: decl.name.text
        case let decl as ActorDeclSyntax: decl.name.text
        case let decl as ClassDeclSyntax: decl.name.text
        case let decl as StructDeclSyntax: decl.name.text
        default: "<unexpected>"
        }
    }
    
    static func parseAccessModifiers(_ modifiers: DeclModifierListSyntax) -> DeclModifierListSyntax {
        let modifiers = modifiers.compactMap { modifier -> DeclModifierSyntax? in
            switch modifier.name.text {
            case "open", "public": return DeclModifierSyntax(name: .keyword(.public))
            case "fileprivate": return DeclModifierSyntax(name: .keyword(.fileprivate))
            case "private": return DeclModifierSyntax(name: .keyword(.private))
            default: return nil
            }
        }
        return DeclModifierListSyntax {
            for modifier in modifiers {
                modifier
            }
        }
    }
    
    static func makeCodingKeys(modifiers: DeclModifierListSyntax, properties: [VariableDeclSyntax]) -> EnumDeclSyntax {
        EnumDeclSyntax(
            modifiers: modifiers,
            name: .identifier("CodingKeys"),
            inheritanceClause: InheritanceClauseSyntax(
                inheritedTypes: InheritedTypeListSyntax {
                    InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "String"))
                    InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "CodingKey"))
                }
            ),
            memberBlock: MemberBlockSyntax(
                members: MemberBlockItemListSyntax {
                    for enumCase in properties.makeCodingKeysEnumCases() {
                        MemberBlockItemSyntax(decl: enumCase)
                    }
                }
            )
        )
    }
    
    static func makeDecodableConstructor(modifiers: DeclModifierListSyntax, properties: [VariableDeclSyntax]) -> InitializerDeclSyntax {
        InitializerDeclSyntax(
            modifiers: modifiers,
            signature: FunctionSignatureSyntax(
                parameterClause: FunctionParameterClauseSyntax(
                    parameters: FunctionParameterListSyntax {
                        FunctionParameterSyntax(
                            firstName: "from",
                            secondName: "decoder",
                            type: SomeOrAnyTypeSyntax(
                                someOrAnySpecifier: .keyword(.any),
                                constraint: IdentifierTypeSyntax(name: "Decoder")
                            )
                        )
                    }
                ),
                effectSpecifiers: FunctionEffectSpecifiersSyntax(throwsSpecifier: .keyword(.throws))
            ),
            body: CodeBlockSyntax(
                statements: CodeBlockItemListSyntax {
                    "let container = try decoder.container(keyedBy: CodingKeys.self)"
                    for property in properties.compactMap({ $0.parseNameType() }) {
                        let name = property.name
                        let type = property.type
                        "\(raw: name) = try container.decode(\(raw: type).self, forKey: .\(raw: name))"
                    }
                }
            )
        )
    }
}

// MARK: - Components

extension DecodableMacro {
    
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
            case .unsupportedType: "@Decodable only supports struct or class at this time"
            }
        }
    }
}
