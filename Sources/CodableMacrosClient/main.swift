import CodableMacros

// MARK: - Decodable

@Decodable struct DecodableUserNoProperties {
    
}

@Decodable class DecodableUserClassNoProperties {
    
}

@Decodable final class DecodableUserFinalClassNoProperties {
    
}

@Decodable struct DecodableUser {
    
    let id: String
    
    @CodingKey("user_name")
    var username: String
}

@Decodable class DecodableUserClass {
    
    @CodingKey("user_data")
    var user: DecodableUser
    
    init(user: DecodableUser) {
        self.user = user
    }
}

@Decodable final class DecodableUserFinalClass {
    
    @CodingKey("user_data")
    var user: DecodableUser
    
    init(user: DecodableUser) {
        self.user = user
    }
}

@Decodable struct DecodableValues {
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

@Decodable class DecodableValuesClass {
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

// MARK: - Encodable

@Encodable struct EncodableUserNoProperties {
    
}

@Encodable class EncodableUserClassNoProperties {
    
}

@Encodable final class EncodableUserFinalClassNoProperties {
    
}

@Encodable struct EncodableUser {
    
    let id: String
    
    @CodingKey("user_name")
    var username: String
}

@Encodable class EncodableUserClass {
    
    let id: String
    
    @CodingKey("user_name")
    var username: String
    
    init(id: String, username: String) {
        self.id = id
        self.username = username
    }
}

// MARK: - Codable

@Codable struct CodableUserNoProperties {
    
}

@Codable class CodableUserClassNoProperties {

}

@Codable final class CodableUserFinalClassNoProperties {

}

@Codable struct CodableUser {
    
    let id: String
    
    @CodingKey("user_name")
    var username: String
}

@Codable class CodableUserClass {
    
    let id: String
    
    @CodingKey("user_name")
    var username: String
}

@Codable final class CodableUserFinalClass {
    
    let id: String
    
    @CodingKey("user_name")
    var username: String
}

@Codable struct CodableValues {
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

@Codable class CodableValuesClass {
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
