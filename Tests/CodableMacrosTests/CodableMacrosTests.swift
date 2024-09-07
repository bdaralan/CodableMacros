import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(CodableMacrosMacros)
import CodableMacrosMacros

let testMacros: [String: Macro.Type] = [
    "Codable": CodableMacro.self,
    "Decodable": DecodableMacro.self,
    "Encodable": EncodableMacro.self,
    "CodingKey": CodingKeyMacro.self
]
#endif

final class CodableMacrosTests: XCTestCase {
    
    func test_Decodable_macro_on_struct_no_properties() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Decodable
        public struct User {
        
        }
        """
        let expansion = """
        public struct User {
        
        }

        extension User: Decodable {
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
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
    
    func test_CodingKey_macro_on_class() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Encodable
        public final class User {
        
            let id: String
            
            @CodingKey("user_name")
            var username: String
        }
        """
        let expansion = """
        public final class User {

            let id: String
            
            var username: String
        }

        extension User: Encodable {

            public enum CodingKeys: String, CodingKey {
                case id
                case username = "user_name"
            }

            public func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(id, forKey: .id)
                try container.encode(username, forKey: .username)
            }
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_Decodable_macro_on_class_no_properties() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Decodable
        public class User {

            public init() {}
        }
        """
        let expansion = """
        public class User {
        
            public init() {}

            public required init(from decoder: any Decoder) throws {
            }
        }

        extension User: Decodable {
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_Decodable_macro_on_final_class_no_properties() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Decodable
        public final class User {

            public init() {}
        }
        """
        let expansion = """
        public final class User {
        
            public init() {}

            public init(from decoder: any Decoder) throws {
            }
        }

        extension User: Decodable {
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
    
    func test_Decodable_macro_on_struct_initial_value() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Decodable
        public struct Values {
            var string1: String = "str1"
            var string2: String = String("str2")
            var string3: String = String(3)
            var string4: String = String(4.0)
            var string5: String = .init()
            var integer1: Int = 1
            var integer2: Int = Int(2)
            var integer3: Int = Int(3.0)
            var integer4: Int = .min
            var double1: Double = 1
            var double2: Double = 2.0
            var double3: Double = Double(3)
            var double4: Double = Double(4.0)
            var double5: Double = .pi
            var boolean1: Bool = true
            var boolean2: Bool = false
            var boolean3: Bool = Bool(true)
            var boolean4: Bool = Bool(false)
            var boolean5: Bool = .random()
        }
        """
        let expansion = """
        public struct Values {
            var string1: String = "str1"
            var string2: String = String("str2")
            var string3: String = String(3)
            var string4: String = String(4.0)
            var string5: String = .init()
            var integer1: Int = 1
            var integer2: Int = Int(2)
            var integer3: Int = Int(3.0)
            var integer4: Int = .min
            var double1: Double = 1
            var double2: Double = 2.0
            var double3: Double = Double(3)
            var double4: Double = Double(4.0)
            var double5: Double = .pi
            var boolean1: Bool = true
            var boolean2: Bool = false
            var boolean3: Bool = Bool(true)
            var boolean4: Bool = Bool(false)
            var boolean5: Bool = .random()
        }

        extension Values: Decodable {

            public enum CodingKeys: String, CodingKey {
                case string1
                case string2
                case string3
                case string4
                case string5
                case integer1
                case integer2
                case integer3
                case integer4
                case double1
                case double2
                case double3
                case double4
                case double5
                case boolean1
                case boolean2
                case boolean3
                case boolean4
                case boolean5
            }

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                string1 = try container.decodeIfPresent(String.self, forKey: .string1) ?? "str1"
                string2 = try container.decodeIfPresent(String.self, forKey: .string2) ?? String("str2")
                string3 = try container.decodeIfPresent(String.self, forKey: .string3) ?? String(3)
                string4 = try container.decodeIfPresent(String.self, forKey: .string4) ?? String(4.0)
                string5 = try container.decodeIfPresent(String.self, forKey: .string5) ?? .init()
                integer1 = try container.decodeIfPresent(Int.self, forKey: .integer1) ?? 1
                integer2 = try container.decodeIfPresent(Int.self, forKey: .integer2) ?? Int(2)
                integer3 = try container.decodeIfPresent(Int.self, forKey: .integer3) ?? Int(3.0)
                integer4 = try container.decodeIfPresent(Int.self, forKey: .integer4) ?? .min
                double1 = try container.decodeIfPresent(Double.self, forKey: .double1) ?? 1
                double2 = try container.decodeIfPresent(Double.self, forKey: .double2) ?? 2.0
                double3 = try container.decodeIfPresent(Double.self, forKey: .double3) ?? Double(3)
                double4 = try container.decodeIfPresent(Double.self, forKey: .double4) ?? Double(4.0)
                double5 = try container.decodeIfPresent(Double.self, forKey: .double5) ?? .pi
                boolean1 = try container.decodeIfPresent(Bool.self, forKey: .boolean1) ?? true
                boolean2 = try container.decodeIfPresent(Bool.self, forKey: .boolean2) ?? false
                boolean3 = try container.decodeIfPresent(Bool.self, forKey: .boolean3) ?? Bool(true)
                boolean4 = try container.decodeIfPresent(Bool.self, forKey: .boolean4) ?? Bool(false)
                boolean5 = try container.decodeIfPresent(Bool.self, forKey: .boolean5) ?? .random()
            }
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_Decodable_macro_on_class_initial_value() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Decodable
        public class Values {
            var string1: String = "str1"
            var string2: String = String("str2")
            var string3: String = String(3)
            var string4: String = String(4.0)
            var string5: String = .init()
            var integer1: Int = 1
            var integer2: Int = Int(2)
            var integer3: Int = Int(3.0)
            var integer4: Int = .min
            var double1: Double = 1
            var double2: Double = 2.0
            var double3: Double = Double(3)
            var double4: Double = Double(4.0)
            var double5: Double = .pi
            var boolean1: Bool = true
            var boolean2: Bool = false
            var boolean3: Bool = Bool(true)
            var boolean4: Bool = Bool(false)
            var boolean5: Bool = .random()
        }
        """
        let expansion = """
        public class Values {
            var string1: String = "str1"
            var string2: String = String("str2")
            var string3: String = String(3)
            var string4: String = String(4.0)
            var string5: String = .init()
            var integer1: Int = 1
            var integer2: Int = Int(2)
            var integer3: Int = Int(3.0)
            var integer4: Int = .min
            var double1: Double = 1
            var double2: Double = 2.0
            var double3: Double = Double(3)
            var double4: Double = Double(4.0)
            var double5: Double = .pi
            var boolean1: Bool = true
            var boolean2: Bool = false
            var boolean3: Bool = Bool(true)
            var boolean4: Bool = Bool(false)
            var boolean5: Bool = .random()
        
            public required init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                string1 = try container.decodeIfPresent(String.self, forKey: .string1) ?? "str1"
                string2 = try container.decodeIfPresent(String.self, forKey: .string2) ?? String("str2")
                string3 = try container.decodeIfPresent(String.self, forKey: .string3) ?? String(3)
                string4 = try container.decodeIfPresent(String.self, forKey: .string4) ?? String(4.0)
                string5 = try container.decodeIfPresent(String.self, forKey: .string5) ?? .init()
                integer1 = try container.decodeIfPresent(Int.self, forKey: .integer1) ?? 1
                integer2 = try container.decodeIfPresent(Int.self, forKey: .integer2) ?? Int(2)
                integer3 = try container.decodeIfPresent(Int.self, forKey: .integer3) ?? Int(3.0)
                integer4 = try container.decodeIfPresent(Int.self, forKey: .integer4) ?? .min
                double1 = try container.decodeIfPresent(Double.self, forKey: .double1) ?? 1
                double2 = try container.decodeIfPresent(Double.self, forKey: .double2) ?? 2.0
                double3 = try container.decodeIfPresent(Double.self, forKey: .double3) ?? Double(3)
                double4 = try container.decodeIfPresent(Double.self, forKey: .double4) ?? Double(4.0)
                double5 = try container.decodeIfPresent(Double.self, forKey: .double5) ?? .pi
                boolean1 = try container.decodeIfPresent(Bool.self, forKey: .boolean1) ?? true
                boolean2 = try container.decodeIfPresent(Bool.self, forKey: .boolean2) ?? false
                boolean3 = try container.decodeIfPresent(Bool.self, forKey: .boolean3) ?? Bool(true)
                boolean4 = try container.decodeIfPresent(Bool.self, forKey: .boolean4) ?? Bool(false)
                boolean5 = try container.decodeIfPresent(Bool.self, forKey: .boolean5) ?? .random()
            }
        }

        extension Values: Decodable {

            public enum CodingKeys: String, CodingKey {
                case string1
                case string2
                case string3
                case string4
                case string5
                case integer1
                case integer2
                case integer3
                case integer4
                case double1
                case double2
                case double3
                case double4
                case double5
                case boolean1
                case boolean2
                case boolean3
                case boolean4
                case boolean5
            }
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_Encodable_macro_on_struct() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Encodable
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
        
        extension User: Encodable {
        
            public enum CodingKeys: String, CodingKey {
                case id
                case username
            }
        
            public func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(id, forKey: .id)
                try container.encode(username, forKey: .username)
            }
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_Encodable_macro_on_class() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Encodable
        public class User {
        
            let id: String
        
            var username: String
        }
        """
        let expansion = """
        public class User {
        
            let id: String
        
            var username: String
        }

        extension User: Encodable {
        
            public enum CodingKeys: String, CodingKey {
                case id
                case username
            }
        
            public func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(id, forKey: .id)
                try container.encode(username, forKey: .username)
            }
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_Codable_macro_on_struct() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Codable
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
        
        extension User: Decodable, Encodable {
        
            public enum CodingKeys: String, CodingKey {
                case id
                case username
            }
        
            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                id = try container.decode(String.self, forKey: .id)
                username = try container.decode(String.self, forKey: .username)
            }
        
            public func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(id, forKey: .id)
                try container.encode(username, forKey: .username)
            }
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_Codable_macro_on_class() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Codable
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
        
        extension User: Decodable, Encodable {
        
            public enum CodingKeys: String, CodingKey {
                case id
                case username
            }
        
            public func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(id, forKey: .id)
                try container.encode(username, forKey: .username)
            }
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_Codable_macro_on_final_class() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Codable
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
        
        extension User: Decodable, Encodable {
        
            public enum CodingKeys: String, CodingKey {
                case id
                case username
            }
        
            public func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(id, forKey: .id)
                try container.encode(username, forKey: .username)
            }
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_Decodable_Encodable_macros_when_uses_together_shows_fixit_replace_with_Codable() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Decodable
        @Encodable
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
        """
        let message = "@Decodable and @Encodable cannot be applied together"
        let fixit = FixItSpec(message: "Replace with @Codable")
        let diagnostic = DiagnosticSpec(message: message, line: 1, column: 1, fixIts: [fixit])
        assertMacroExpansion(declaration, expandedSource: expansion, diagnostics: [diagnostic], macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
