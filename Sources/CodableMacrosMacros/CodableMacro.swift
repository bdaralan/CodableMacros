import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public enum CodableMacro {}

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
        
        // show error message and fixit for change @Codable to @Decodable and @Encodable
        var updateDeclaration = declaration
        updateDeclaration.attributes.update(removing: ["Codable"], adding: ["Decodable", "Encodable"])
        let change = FixIt.Change.replace(oldNode: Syntax(declaration), newNode: Syntax(updateDeclaration))
        let fixit = FixIt(message: FixMessage.changeCodableToDecodableEncodable, changes: [change])
        context.diagnose(Diagnostic(node: node, message: Message.changeCodableToDecodableEncodable, fixIt: fixit))
        
        return []
    }
}

// MARK: - Diagnostic

extension CodableMacro {
    
    enum Message: String, DiagnosticMessage {
        
        case unsupportedType
        
        case changeCodableToDecodableEncodable
        
        case unexpected
        
        var diagnosticID: MessageID {
            MessageID(domain: "CodableMacros", id: rawValue)
        }
    
        var severity: DiagnosticSeverity {
            switch self {
            case .unsupportedType: .error
            case .changeCodableToDecodableEncodable: .error
            case .unexpected: .error
            }
        }
        
        var message: String {
            switch self {
            case .unsupportedType: "@Codable only supports struct or class at this time"
            case .changeCodableToDecodableEncodable: "@Codable is currently unavailable change to @Decodable and @Encodable"
            case .unexpected: "Encounter unexpected use case"
            }
        }
    }
    
    enum FixMessage: FixItMessage {
        
        case changeCodableToDecodableEncodable
        
        var message: String {
            switch self {
            case .changeCodableToDecodableEncodable: "Change @Codable to @Decodable and @Encodable"
            }
        }
        
        var fixItID: MessageID {
            switch self {
            case .changeCodableToDecodableEncodable: Message.changeCodableToDecodableEncodable.diagnosticID
            }
        }
    }
}
