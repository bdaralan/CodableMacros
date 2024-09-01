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
        guard declaration.is(StructDeclSyntax.self) else {
            context.diagnose(Diagnostic(node: node, message: Message.onlySupportStruct))
            return []
        }
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
        guard let declaration = declaration.as(StructDeclSyntax.self) else { return [] }
        
        let mappedAccessModifiers = declaration.modifiers.compactMap { modifier -> DeclModifierSyntax? in
            switch modifier.name.text {
            case "open", "public": return DeclModifierSyntax(name: .keyword(.public))
            case "fileprivate": return DeclModifierSyntax(name: .keyword(.fileprivate))
            case "private": return DeclModifierSyntax(name: .keyword(.private))
            default: return nil
            }
        }
        
        let accessModifiers = DeclModifierListSyntax {
            for modifier in mappedAccessModifiers {
                modifier
            }
        }
        
        let storedProperties = declaration.memberBlock.members.filterDecodableStoredProperties()
        
        let enumCodingKeys = EnumDeclSyntax(
            modifiers: accessModifiers,
            name: .identifier("CodingKeys"),
            inheritanceClause: InheritanceClauseSyntax(
                inheritedTypes: InheritedTypeListSyntax {
                    InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "String"))
                    InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "CodingKey"))
                }
            ),
            memberBlock: MemberBlockSyntax(
                members: MemberBlockItemListSyntax {
                    for enumCase in storedProperties.makeCodingKeysEnumCases() {
                        MemberBlockItemSyntax(decl: enumCase)
                    }
                }
            )
        )
        
        
        let initFromDecoder = InitializerDeclSyntax(
            modifiers: accessModifiers,
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
                    for property in storedProperties.compactMap({ $0.parsedNameType() }) {
                        let name = property.name
                        let type = property.type
                        "\(raw: name) = try container.decode(\(raw: type).self, forKey: .\(raw: name))"
                    }
                }
            )
        )
        
        let extensionInheritanceClause = InheritanceClauseSyntax(
            inheritedTypes: InheritedTypeListSyntax {
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "Decodable"))
            }
        )
        
        let extensionDecl = ExtensionDeclSyntax(
            extendedType: IdentifierTypeSyntax(name: .identifier(declaration.name.text)),
            inheritanceClause: extensionInheritanceClause,
            memberBlock: MemberBlockSyntax(
                members: MemberBlockItemListSyntax {
                    MemberBlockItemSyntax(leadingTrivia: .newlines(2), decl: enumCodingKeys)
                    MemberBlockItemSyntax(leadingTrivia: .newlines(2), decl: initFromDecoder)
                }
            )
        )
        
        return [extensionDecl]
    }
}

// MARK: - ExpansionError

extension DecodableMacro {
    
    enum Message: String, DiagnosticMessage {
        
        case onlySupportStruct
        
        var diagnosticID: MessageID {
            MessageID(domain: "CodableMacros", id: rawValue)
        }
    
        var severity: DiagnosticSeverity {
            switch self {
            case .onlySupportStruct: .error
            }
        }
        
        var message: String {
            switch self {
            case .onlySupportStruct: "@Decodable only supports struct at this time"
            }
        }
    }
}

extension MemberBlockItemListSyntax {
    
    /// Filters for declarations that are stored properties which will be decoded.
    func filterDecodableStoredProperties() -> [VariableDeclSyntax] {
        compactMap { member -> VariableDeclSyntax? in
            guard let variable = member.decl.as(VariableDeclSyntax.self) else { return nil }
            guard let binding = variable.bindings.first else { return nil }
            guard binding.accessorBlock == nil else { return nil }
            return variable
        }
    }
}

extension VariableDeclSyntax {
    
    /// Returns a given string inside the `@CodingKey` attribute.
    ///
    /// Returns `nil` when the declaration does not have this attribute.
    func parsedAttributeCodingKeyRawValue() -> String? {
        for attribute in attributes {
            guard let attribute = attribute.as(AttributeSyntax.self) else { continue }
            guard let attributeName = attribute.attributeName.as(IdentifierTypeSyntax.self) else { continue }
            guard attributeName.name.text == "CodingKey" else { continue }
            guard let arguments = attribute.arguments?.as(LabeledExprListSyntax.self) else { continue }
            guard let argument = arguments.first else { continue }
            guard let expression = argument.expression.as(StringLiteralExprSyntax.self) else { continue }
            guard let segment = expression.segments.first?.as(StringSegmentSyntax.self) else { continue }
            return segment.content.text
        }
        return nil
    }
    
    func parsedNameType() -> (name: String, type: String)? {
        guard let binding = bindings.first else { return nil }
        guard binding.accessorBlock == nil else { return nil }
        guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else { return nil }
        guard let typeAnnotation = binding.typeAnnotation else { return nil }
        guard let type = typeAnnotation.type.as(IdentifierTypeSyntax.self) else { return nil }
        return (pattern.identifier.text, type.name.text)
    }
}

extension Collection where Element == VariableDeclSyntax {
    
    /// Maps each declaration into enum case declaration.
    func makeCodingKeysEnumCases() -> [EnumCaseDeclSyntax] {
        compactMap { decl -> EnumCaseDeclSyntax? in
            guard let binding = decl.bindings.first else { return nil }
            guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else { return nil }
            let atCodingKeyRawValue = decl.parsedAttributeCodingKeyRawValue()
            let caseName = pattern.identifier
            let caseRawValue = atCodingKeyRawValue.map { caseRawValue in
                InitializerClauseSyntax(value: StringLiteralExprSyntax(content: caseRawValue))
            }
            let caseDecl = EnumCaseDeclSyntax {
                EnumCaseElementSyntax(name: caseName, rawValue: caseRawValue)
            }
            return caseDecl
        }
    }
}
