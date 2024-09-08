import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. 
// Cross-compiled tests may still make use of the macro itself in end-to-end tests.
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
    
    // MARK: Decodable
    
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
                self.id = try container.decode(String.self, forKey: .id)
                self.username = try container.decode(String.self, forKey: .username)
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
                self.id = try container.decode(String.self, forKey: .id)
                self.username = try container.decode(String.self, forKey: .username)
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
                self.id = try container.decode(String.self, forKey: .id)
                self.username = try container.decode(String.self, forKey: .username)
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
                self.string1 = try container.decodeIfPresent(String.self, forKey: .string1) ?? "str1"
                self.string2 = try container.decodeIfPresent(String.self, forKey: .string2) ?? String("str2")
                self.string3 = try container.decodeIfPresent(String.self, forKey: .string3) ?? String(3)
                self.string4 = try container.decodeIfPresent(String.self, forKey: .string4) ?? String(4.0)
                self.string5 = try container.decodeIfPresent(String.self, forKey: .string5) ?? .init()
                self.integer1 = try container.decodeIfPresent(Int.self, forKey: .integer1) ?? 1
                self.integer2 = try container.decodeIfPresent(Int.self, forKey: .integer2) ?? Int(2)
                self.integer3 = try container.decodeIfPresent(Int.self, forKey: .integer3) ?? Int(3.0)
                self.integer4 = try container.decodeIfPresent(Int.self, forKey: .integer4) ?? .min
                self.double1 = try container.decodeIfPresent(Double.self, forKey: .double1) ?? 1
                self.double2 = try container.decodeIfPresent(Double.self, forKey: .double2) ?? 2.0
                self.double3 = try container.decodeIfPresent(Double.self, forKey: .double3) ?? Double(3)
                self.double4 = try container.decodeIfPresent(Double.self, forKey: .double4) ?? Double(4.0)
                self.double5 = try container.decodeIfPresent(Double.self, forKey: .double5) ?? .pi
                self.boolean1 = try container.decodeIfPresent(Bool.self, forKey: .boolean1) ?? true
                self.boolean2 = try container.decodeIfPresent(Bool.self, forKey: .boolean2) ?? false
                self.boolean3 = try container.decodeIfPresent(Bool.self, forKey: .boolean3) ?? Bool(true)
                self.boolean4 = try container.decodeIfPresent(Bool.self, forKey: .boolean4) ?? Bool(false)
                self.boolean5 = try container.decodeIfPresent(Bool.self, forKey: .boolean5) ?? .random()
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
                self.string1 = try container.decodeIfPresent(String.self, forKey: .string1) ?? "str1"
                self.string2 = try container.decodeIfPresent(String.self, forKey: .string2) ?? String("str2")
                self.string3 = try container.decodeIfPresent(String.self, forKey: .string3) ?? String(3)
                self.string4 = try container.decodeIfPresent(String.self, forKey: .string4) ?? String(4.0)
                self.string5 = try container.decodeIfPresent(String.self, forKey: .string5) ?? .init()
                self.integer1 = try container.decodeIfPresent(Int.self, forKey: .integer1) ?? 1
                self.integer2 = try container.decodeIfPresent(Int.self, forKey: .integer2) ?? Int(2)
                self.integer3 = try container.decodeIfPresent(Int.self, forKey: .integer3) ?? Int(3.0)
                self.integer4 = try container.decodeIfPresent(Int.self, forKey: .integer4) ?? .min
                self.double1 = try container.decodeIfPresent(Double.self, forKey: .double1) ?? 1
                self.double2 = try container.decodeIfPresent(Double.self, forKey: .double2) ?? 2.0
                self.double3 = try container.decodeIfPresent(Double.self, forKey: .double3) ?? Double(3)
                self.double4 = try container.decodeIfPresent(Double.self, forKey: .double4) ?? Double(4.0)
                self.double5 = try container.decodeIfPresent(Double.self, forKey: .double5) ?? .pi
                self.boolean1 = try container.decodeIfPresent(Bool.self, forKey: .boolean1) ?? true
                self.boolean2 = try container.decodeIfPresent(Bool.self, forKey: .boolean2) ?? false
                self.boolean3 = try container.decodeIfPresent(Bool.self, forKey: .boolean3) ?? Bool(true)
                self.boolean4 = try container.decodeIfPresent(Bool.self, forKey: .boolean4) ?? Bool(false)
                self.boolean5 = try container.decodeIfPresent(Bool.self, forKey: .boolean5) ?? .random()
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
    
    // MARK: Encodable
    
    func test_Encodable_macro_on_struct_no_properties() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Encodable
        public struct User {
        
        }
        """
        let expansion = """
        public struct User {
        
        }
        
        extension User: Encodable {
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_Encodable_macro_on_class_no_properties() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Encodable
        public class User {

            public init() {}
        }
        """
        let expansion = """
        public class User {

            public init() {}
        
            public func encode(to encoder: any Encoder) throws {
            }
        }
        
        extension User: Encodable {
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_Encodable_macro_on_final_class_no_properties() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Encodable
        public final class User {

            public init() {}
        }
        """
        let expansion = """
        public final class User {

            public init() {}
        
            public func encode(to encoder: any Encoder) throws {
            }
        }
        
        extension User: Encodable {
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
                try container.encode(self.id, forKey: .id)
                try container.encode(self.username, forKey: .username)
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
        
            public func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(self.id, forKey: .id)
                try container.encode(self.username, forKey: .username)
            }
        }

        extension User: Encodable {
        
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
    
    // MARK: Decodable & Encodable
    
    func test_Decodable_Encodable_macros_on_struct_no_properties() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Decodable
        @Encodable
        public struct User {
        
        }
        """
        let expansion = """
        public struct User {
        
        }
        
        extension User: Decodable {
        }
        
        extension User: Encodable {
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_Decodable_Encodable_macros_on_class_no_properties() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Decodable
        @Encodable
        public class User {

            public init() {}
        }
        """
        let expansion = """
        public class User {
        
            public init() {}
        
            public required init(from decoder: any Decoder) throws {
            }

            public func encode(to encoder: any Encoder) throws {
            }
        }
        
        extension User: Decodable {
        }
        
        extension User: Encodable {
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_Decodable_Encodable_macros_on_final_class_no_properties() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Decodable
        @Encodable
        public final class User {

            public init() {}
        }
        """
        let expansion = """
        public final class User {
        
            public init() {}
        
            public init(from decoder: any Decoder) throws {
            }

            public func encode(to encoder: any Encoder) throws {
            }
        }
        
        extension User: Decodable {
        }
        
        extension User: Encodable {
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_Decodable_Encodable_macros_on_struct() throws {
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
        
        extension User: Decodable {

            public enum CodingKeys: String, CodingKey {
                case id
                case username
            }

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.id = try container.decode(String.self, forKey: .id)
                self.username = try container.decode(String.self, forKey: .username)
            }
        }
        
        extension User: Encodable {

            public func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(self.id, forKey: .id)
                try container.encode(self.username, forKey: .username)
            }
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_Decodable_Encodable_macros_on_class() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Decodable
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
        
            public required init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.id = try container.decode(String.self, forKey: .id)
                self.username = try container.decode(String.self, forKey: .username)
            }
        
            public func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(self.id, forKey: .id)
                try container.encode(self.username, forKey: .username)
            }
        }
        
        extension User: Decodable {

            public enum CodingKeys: String, CodingKey {
                case id
                case username
            }
        }
        
        extension User: Encodable {
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_Decodable_Encodable_macros_on_final_class() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Decodable
        @Encodable
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
                self.id = try container.decode(String.self, forKey: .id)
                self.username = try container.decode(String.self, forKey: .username)
            }
        
            public func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(self.id, forKey: .id)
                try container.encode(self.username, forKey: .username)
            }
        }
        
        extension User: Decodable {

            public enum CodingKeys: String, CodingKey {
                case id
                case username
            }
        }
        
        extension User: Encodable {
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    // MARK: Codable
    
    func test_Codable_macro_shows_fixit_change_to_Decodable_Encodable() throws {
        #if canImport(CodableMacrosMacros)
        let declaration =  """
        @Codable public struct User {}
        """
        let expansion = """
        public struct User {}
        """
        let message = "@Codable is currently unavailable change to @Decodable and @Encodable"
        let fixit = FixItSpec(message: "Change @Codable to @Decodable and @Encodable")
        let diagnostic = DiagnosticSpec(message: message, line: 1, column: 1, severity: .error, fixIts: [fixit])
        assertMacroExpansion(declaration, expandedSource: expansion, diagnostics: [diagnostic], macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    // MARK: CodingKey
    
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
                self.id = try container.decode(String.self, forKey: .id)
                self.username = try container.decode(String.self, forKey: .username)
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
        public class User {
        
            let id: String
            
            @CodingKey("user_name")
            var username: String
        }
        """
        let expansion = """
        public class User {

            let id: String
            
            var username: String

            public func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(self.id, forKey: .id)
                try container.encode(self.username, forKey: .username)
            }
        }

        extension User: Encodable {

            public enum CodingKeys: String, CodingKey {
                case id
                case username = "user_name"
            }
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func test_CodingKey_macro_on_final_class() throws {
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

            public func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(self.id, forKey: .id)
                try container.encode(self.username, forKey: .username)
            }
        }

        extension User: Encodable {

            public enum CodingKeys: String, CodingKey {
                case id
                case username = "user_name"
            }
        }
        """
        assertMacroExpansion(declaration, expandedSource: expansion, macros: testMacros)
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
