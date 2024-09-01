import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension MemberBlockItemListSyntax {
    
    /// Filters for declarations that are stored properties.
    func filterStoredProperties() -> [VariableDeclSyntax] {
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
    func parseAttributeCodingKeyRawValue() -> String? {
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
    
    func parseNameType() -> (name: String, type: String)? {
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
            let atCodingKeyRawValue = decl.parseAttributeCodingKeyRawValue()
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
