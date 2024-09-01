import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(CodableMacrosMacros)
import CodableMacrosMacros

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
    "Decodable": DecodableMacro.self
]
#endif

final class CodableMacrosTests: XCTestCase {
    
    func testDecodableMacro() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Decodable 
        public struct User {
            
            let id: String
            
            var username: String
        }
        """
        let expansion = """
        public struct User {
            
            let id: String
            
            var username: String
        }
        
        extension User: Decodable {
        
            public enum CodingKeys: String, CodingKey {
                case id
                case username
            }
        
            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                id = try container.decode(String.self, forKey: .id)
                username = try container.decode(String.self, forKey: .username)
            }
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
