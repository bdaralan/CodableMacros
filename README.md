# CodableMacros

A list of macros that help remove some boilerplate codes when working with `Codable`.
The goal is to make working with `Codable` easier in most use cases but not to replace `Codable`.

``` swift
// Attach Decodable() or Encodable() macro to struct or class

@Decodable @Encodable struct User {

  // behaves the same way as Codable protocol
  let id: String

  // provides custom key for CodingKeys enum
  @CodingKey("user_tag") let username: String

  // provides initial value when decode value is not presented
  var biography: String = ""
}
```

``` swift
// Decodable() and Encodable() macros expansion

extension User: Decodable {

    enum CodingKeys: String, CodingKey {
        case id
        case username = "user_tag"
        case biography
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        biography = try container.decodeIfPresent(String.self, forKey: .biography) ?? ""
    }
}

extension User: Encodable {

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(biography, forKey: .biography)
    }
}
```
