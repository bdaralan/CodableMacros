import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public enum CodableMacro {
    
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
            case .unsupportedType: "@Codable only supports struct or class at this time"
            }
        }
    }
}

// MARK: - MemberMacro

extension CodableMacro: MemberMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        if declaration.is(StructDeclSyntax.self) {
            return []
        }
        
        if declaration.is(ClassDeclSyntax.self) {
            var modifiers = DecodableMacro.parseAccessModifiers(declaration.modifiers)
            
            // the decodable init needs required keyword when class doesn't have final keyword
            if !declaration.modifiers.lazy.map(\.name.text).contains("final") {
                modifiers.append(DeclModifierSyntax(name: .keyword(.required)))
            }
            
            let properties = declaration.memberBlock.members.filterStoredProperties()
            let decodableConstructor = DecodableMacro.makeDecodableConstructor(modifiers: modifiers, properties: properties)
            return [DeclSyntax(decodableConstructor)]
        }
        
        // show unsupported declaration diagnostic message
        context.diagnose(Diagnostic(node: node, message: Message.unsupportedType))
        return []
    }
}

// MARK: - ExtensionMacro

extension CodableMacro: ExtensionMacro {

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
                InheritedTypeSyntax(type: IdentifierTypeSyntax(name: "Codable"))
            }
        )
        
        let extensionMembers = MemberBlockItemListSyntax {
            if !properties.isEmpty {
                MemberBlockItemSyntax(leadingTrivia: .newlines(2), decl: enumCodingKeys)
            }
            if declaration.is(StructDeclSyntax.self) && !properties.isEmpty {
                let decodableConstructor = DecodableMacro.makeDecodableConstructor(modifiers: modifiers, properties: properties)
                MemberBlockItemSyntax(leadingTrivia: .newlines(2), decl: decodableConstructor)
            }
            if declaration.is(ClassDeclSyntax.self) || !properties.isEmpty {
                MemberBlockItemSyntax(
                    leadingTrivia: .newlines(2),
                    decl: EncodableMacro.makeEncodableEncodeMethod(modifiers: modifiers, properties: properties)
                )
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
