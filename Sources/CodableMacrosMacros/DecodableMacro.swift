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
        
        // for class the macro expands the constructor and encode method in the class declaration
        // then expands everything else in the extension
        if declaration.is(ClassDeclSyntax.self) {
            let modifiers = parseAccessModifiers(declaration.modifiers)
            let properties = declaration.memberBlock.members.filterStoredProperties()
            var decodableConstructor = makeDecodableConstructor(modifiers: modifiers, properties: properties)
            
            // the decodable init needs required keyword when class doesn't have final keyword
            if !declaration.modifiers.lazy.map(\.name.text).contains("final") {
                let requiredKeyword = DeclModifierSyntax(name: .keyword(.required))
                decodableConstructor.modifiers.append(requiredKeyword)
            }
            
            return [DeclSyntax(decodableConstructor)]
        }
        
        // show unexpected use-case message
        context.diagnose(Diagnostic(node: node, message: Message.unexpected))
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
        
        let extensionInheritanceClause = InheritanceClauseSyntax(
            inheritedTypes: InheritedTypeListSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "Decodable"))
            }
        )
        
        let extensionMembers = MemberBlockItemListSyntax {
            if !properties.isEmpty {
                let enumCodingKeys = makeCodingKeys(modifiers: modifiers, properties: properties)
                MemberBlockItemSyntax(leadingTrivia: .newlines(2), decl: enumCodingKeys)
            }
            if declaration.is(StructDeclSyntax.self) && !properties.isEmpty {
                let decodableConstructor = makeDecodableConstructor(modifiers: modifiers, properties: properties)
                MemberBlockItemSyntax(leadingTrivia: .newlines(2), decl: decodableConstructor)
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
                    if !properties.isEmpty {
                        "let container = try decoder.container(keyedBy: CodingKeys.self)"
                    }
                    for parameters in properties.compactMap({ $0.parseDecodableParameters() }) {
                        let name = parameters.name
                        let type = parameters.type
                        if let value = parameters.initializer?.value.description {
                            "self.\(raw: name) = try container.decodeIfPresent(\(raw: type).self, forKey: .\(raw: name)) ?? \(raw: value)"
                        } else {
                            "self.\(raw: name) = try container.decode(\(raw: type).self, forKey: .\(raw: name))"
                        }
                    }
                }
            )
        )
    }
}

// MARK: - Diagnostic

extension DecodableMacro {
    
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
            case .unsupportedType: "@Decodable only supports struct or class at this time"
            case .unexpected: "Encounter unexpected use case"
            }
        }
    }
}
