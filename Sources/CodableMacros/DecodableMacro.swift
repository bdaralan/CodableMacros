@attached(member)
@attached(extension, conformances: Decodable, names: named(CodingKeys))
public macro Decodable() = #externalMacro(module: "CodableMacrosMacros", type: "DecodableMacro")
