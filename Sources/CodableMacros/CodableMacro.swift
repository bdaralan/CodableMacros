/// ``Codable()`` macro is currently unavailable.
///
/// At the time of this implementation macro doesn't support typealias nor allow peer macro to modify
/// the attributes of a type declaration.
///
/// Therefore, using @Codable will suggest a fix-it to replace `@Codable` with `@Decodable` and `@Encodable`.
///
@attached(member)
public macro Codable() = #externalMacro(module: "CodableMacrosMacros", type: "CodableMacro")
