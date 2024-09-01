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
