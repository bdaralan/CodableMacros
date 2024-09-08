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
    var username: String
}

@Decodable class DecodableUserClass {
    let id: String
    var username: String
}

@Decodable final class DecodableUserFinalClass {
    let id: String
    var username: String
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

@Decodable final class DecodableValuesFinalClass {
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
    var username: String
}

@Encodable class EncodableUserClass {
    let id: String
    var username: String
    
    init(id: String, username: String) {
        self.id = id
        self.username = username
    }
}

@Encodable final class EncodableUserFinalClass {
    let id: String
    var username: String
    
    init(id: String, username: String) {
        self.id = id
        self.username = username
    }
}

// MARK: - CodingKey

@Decodable struct CodingKeyDecodableUser {
    
    let id: String
    
    @CodingKey("user_tag")
    var username: String
    
    @CodingKey("bio")
    var biography: String = ""
}

@Decodable class CodingKeyDecodableUserClass {
    
    let id: String
    
    @CodingKey("user_tag")
    var username: String
    
    @CodingKey("bio")
    var biography: String = ""
}

@Decodable final class CodingKeyDecodableUserFinalClass {
    
    let id: String
    
    @CodingKey("user_tag")
    var username: String
    
    @CodingKey("bio")
    var biography: String = ""
}

@Encodable struct CodingKeyEncodableUser {
    
    let id: String
    
    @CodingKey("user_tag")
    var username: String
    
    @CodingKey("bio")
    var biography: String = ""
}

@Encodable class CodingKeyEncodableUserClass {
    
    let id: String
    
    @CodingKey("user_tag")
    var username: String
    
    @CodingKey("bio")
    var biography: String = ""
    
    init(id: String, username: String, biography: String) {
        self.id = id
        self.username = username
        self.biography = biography
    }
}

@Encodable final class CodingKeyEncodableUserFinalClass {
    
    let id: String
    
    @CodingKey("user_tag")
    var username: String
    
    @CodingKey("bio")
    var biography: String = ""
    
    init(id: String, username: String, biography: String) {
        self.id = id
        self.username = username
        self.biography = biography
    }
}
