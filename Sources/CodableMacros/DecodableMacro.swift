/// Defines and implements conformance of the `Decodable` protocol.
///
/// This macro adds decodable support to a custom type and conforms the type to the `Decodable` protocol.
///
/// ``` swift
/// @Decodable public struct User {
///
///     // behaves the same way as Decodable protocol
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
@attached(member, names: named(CodingKeys), named(init(from:)))
@attached(extension, conformances: Decodable, names: named(CodingKeys), named(init(from:)))
public macro Decodable() = #externalMacro(module: "CodableMacrosMacros", type: "DecodableMacro")
