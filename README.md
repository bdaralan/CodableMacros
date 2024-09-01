# CodableMacros

A list of macros that remove some boilerplate codes when working with `Decodable` and `Encodable`.

``` swift
@Codable public struct User {

  // behaves the same way as Codable protocol
  let id: String

  // provides custom key for CodingKeys enum
  @CodingKey("user_tag") let username: String

  // provides initial value when value is not presented
  var biography: String = ""
}
```

``` swift
extension User: Decodable, Encodable {

    public enum CodingKeys: String, CodingKey {
        case id
        case username = "user_tag"
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
```
