/// Defines and implements conformance of the `Encodable` protocol.
///
/// This macro adds decodable support to a custom type and conforms the type to the `Encodable` protocol.
///
/// ``` swift
/// @Encodable public struct User {
///
///     // behaves the same way as Encodable protocol
///     let id: String
///
///     // provides custom key for CodingKeys enum
///     @CodingKey("user_tag") let username: String
/// }
/// ```
///
@attached(member)
@attached(extension, conformances: Encodable, names: named(CodingKeys), named(encode(to:)))
public macro Encodable() = #externalMacro(module: "CodableMacrosMacros", type: "EncodableMacro")
