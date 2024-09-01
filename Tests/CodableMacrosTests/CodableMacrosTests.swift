import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(CodableMacrosMacros)
import CodableMacrosMacros

let testMacros: [String: Macro.Type] = [
    "Decodable": DecodableMacro.self,
    "CodingKey": CodingKeyMacro.self
]
#endif

final class CodableMacrosTests: XCTestCase {
    
    func test_Decodable_macro_on_struct() throws {
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
    
    func test_CodingKey_macro_on_struct() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Decodable
        public struct User {
        
            let id: String
            
            @CodingKey("user_name")
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
                case username = "user_name"
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
    
    func test_Decodable_macro_on_class() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Decodable
        public class User {
            
            let id: String
            
            var username: String
        }
        """
        let expansion = """
        public class User {
            
            let id: String
            
            var username: String
        
            public required init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                id = try container.decode(String.self, forKey: .id)
                username = try container.decode(String.self, forKey: .username)
            }
        }
        
        extension User: Decodable {
        
            public enum CodingKeys: String, CodingKey {
                case id
                case username
            }
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_Decodable_macro_on_final_class() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Decodable
        public final class User {
            
            let id: String
            
            var username: String
        }
        """
        let expansion = """
        public final class User {
            
            let id: String
            
            var username: String
        
            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                id = try container.decode(String.self, forKey: .id)
                username = try container.decode(String.self, forKey: .username)
            }
        }
        
        extension User: Decodable {
        
            public enum CodingKeys: String, CodingKey {
                case id
                case username
            }
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
