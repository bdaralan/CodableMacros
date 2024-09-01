@attached(member)
@attached(extension, conformances: Decodable, names: named(CodingKeys), named(init(from:)))
public macro Decodable() = #externalMacro(module: "CodableMacrosMacros", type: "DecodableMacro")
