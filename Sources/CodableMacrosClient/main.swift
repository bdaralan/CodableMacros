import CodableMacros

@Decodable public struct User {
    
    let id: String
    
    @CodingKey("user_name")
    var username: String
}

@Decodable public class UserReference {
    
    @CodingKey("user_data")
    var user: User
    
    init(user: User) {
        self.user = user
    }
}

@Decodable public final class UserFinalReference {
    
    @CodingKey("user_data")
    var user: User
    
    init(user: User) {
        self.user = user
    }
}

@Decodable public struct Values {
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

@Decodable public class ValuesReference {
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
