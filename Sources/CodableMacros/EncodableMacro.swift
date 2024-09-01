/// Defines and implements conformance of the `Encodable` protocol.
///
/// This macro adds decodable support to a custom type and conforms the type to the `Encodable` protocol.
///
@attached(member, names: named(CodingKeys), named(encode(to:)))
@attached(extension, conformances: Encodable, names: named(CodingKeys), named(encode(to:)))
public macro Encodable() = #externalMacro(module: "CodableMacrosMacros", type: "EncodableMacro")
