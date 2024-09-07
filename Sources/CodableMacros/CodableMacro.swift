/// Defines and implements conformance of the `Codable` protocol.
///
/// This macro adds codable support to a custom type and conforms the type to the `Codable` protocol.
///
/// ``` swift
/// @Codable public struct User {
///
///     // behaves the same way as Codable protocol
///     let id: String
///
///     // provides custom key for CodingKeys enum
///     @CodingKey("user_tag") let username: String
///
///     // provides initial value when value is not presented
///     var biography: String = ""
/// }
/// ```
///
@attached(member, names: named(CodingKeys), named(init(from:)), named(encode(to:)))
@attached(extension, conformances: Codable, names: named(CodingKeys), named(init(from:)), named(encode(to:)))
public macro Codable() = #externalMacro(module: "CodableMacrosMacros", type: "CodableMacro")
