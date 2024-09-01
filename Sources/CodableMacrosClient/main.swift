import CodableMacros

@Decodable public struct User {
    
    let id: String
    
    @CodingKey("user_name")
    var username: String = "none"
}
