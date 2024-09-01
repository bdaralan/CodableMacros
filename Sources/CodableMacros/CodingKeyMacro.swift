/// A macro that provides custom key for `CodingKeys` enum.
///
/// Use this macro when working with ``CodableMacros/Decodable()``, ``CodableMacros/Encodable()``, or ``CodableMacros/Codable()`` macro to provide custom key.
///
@attached(peer)
public macro CodingKey(_ key: StaticString) = #externalMacro(module: "CodableMacrosMacros", type: "CodingKeyMacro")
