import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public enum CodableMacro {
    
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
            case .unsupportedType: "@Codable only supports struct or class at this time"
            case .unexpected: "Encounter unexpected use case"
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
        let supported = declaration.is(StructDeclSyntax.self) || declaration.is(ClassDeclSyntax.self)
        
        guard supported else {
            // show unsupported declaration diagnostic message
            context.diagnose(Diagnostic(node: node, message: Message.unsupportedType))
            return []
        }
        
        if declaration.is(StructDeclSyntax.self) {
            return []
        }
        
        // for class the macro expands init(from:) and encode(to:) in the declaration
        if declaration.is(ClassDeclSyntax.self) {
            let modifiers = DecodableMacro.parseAccessModifiers(declaration.modifiers)
            let properties = declaration.memberBlock.members.filterStoredProperties()
            
            var decodableConstructor = DecodableMacro.makeDecodableConstructor(modifiers: modifiers, properties: properties)
            
            // non-final class needs to add required key to satisfy the decodable conformance
            if !declaration.modifiers.lazy.map(\.name.text).contains("final") {
                let requiredKeyword = DeclModifierSyntax(name: .keyword(.required))
                decodableConstructor.modifiers.append(requiredKeyword)
            }
            
            let encodableEncodeMethod = EncodableMacro.makeEncodableEncodeMethod(modifiers: modifiers, properties: properties)
            
            return [DeclSyntax(decodableConstructor), DeclSyntax(encodableEncodeMethod)]
        }
        
        // show unexpected use-case message
        context.diagnose(Diagnostic(node: node, message: Message.unexpected))
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
            if declaration.is(StructDeclSyntax.self) && !properties.isEmpty {
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
