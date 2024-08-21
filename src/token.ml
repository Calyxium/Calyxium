module Token = struct
  type token =
    (* Operators *)
    | Plus
    | Minus
    | Star
    | Slash

    (* Symbols *)
    | LParen
    | RParen
    | LBracket
    | RBracket
    | LBrace
    | RBrace
    | Dot
    | Question
    | Colon
    | Semi
    | Comma
    | Not
    | Pipe
    | Amspersand
    | Greater
    | Less

    (* Logical *)
    | LogicalOr
    | LogicalAnd
    | Eq
    | Neq
    | Geq
    | Leq

    (* Assignment *)
    | Assign
    | PlusAssign
    | MinusAssign
    | StarAssign
    | SlashAssign

    (* Keywords *)
    | Function
    | If
    | Else
    | Return
    | Var
    | Const
    | Switch
    | Case
    | Break
    | Default
    | For
    | True
    | False
    | Try
    | Catch
    | Import
    | Export
    | This
    | Null

    (* Types *)
    | IntType
    | FloatType
    | StringType
    | ByteType
    | BoolType

    (* Literals *)
    | Ident of string
    | Int of int
    | Float of float
    | String of string
    | Byte of char
    | Bool of bool

    | EOF

  let string_of_token = function
    (* Operators *)
    | Plus -> "Plus"
    | Minus -> "Minus"
    | Star -> "Star"
    | Slash -> "Slash"

    (* Symbols *)
    | LParen -> "LParen"
    | RParen -> "RParen" 
    | LBracket -> "LBracket"
    | RBracket -> "RBracket"
    | LBrace -> "LBrace"
    | RBrace -> "RBrace"
    | Dot -> "Dot"
    | Question -> "Question"
    | Colon -> "Colon"
    | Semi -> "Semi"
    | Comma -> "Comma"
    | Not -> "Not"
    | Pipe -> "Pipe"
    | Amspersand -> "Amspersand"
    | Greater -> "Greater"
    | Less -> "Less"

    (* Logical *)
    | LogicalOr -> "LogicalOr"
    | LogicalAnd -> "LogicalAnd"
    | Eq -> "Eq"
    | Neq -> "Neq"
    | Geq -> "Geq"
    | Leq -> "Geq"

    (* Assignment *)
    | Assign -> "Assign"
    | PlusAssign -> "PlusAssign"
    | MinusAssign -> "MinusAssign"
    | StarAssign -> "StarAssign"
    | SlashAssign -> "SlashAssign"

    (* Keywords *)
    | Function -> "Function"
    | If -> "If"
    | Else -> "Else"
    | Return -> "Return"
    | Var -> "Var"
    | Const -> "Const"
    | Switch -> "Switch"
    | Case -> "Case"
    | Break -> "Break"
    | Default -> "Default"
    | For -> "For"
    | True -> "True"
    | False -> "False"
    | Try -> "Try"
    | Catch -> "Catch"
    | Import -> "Import"
    | Export -> "Export"
    | This -> "This"
    | Null -> "Null"

    (* Types *)
    | IntType -> "IntType"
    | FloatType -> "FloatType"
    | StringType -> "StringType"
    | ByteType -> "ByteType"
    | BoolType -> "BoolType"

    (* Literals *)
    | Ident s -> "Ident(" ^ s ^ ")"
    | Int i -> "Int(" ^ string_of_int i ^ ")"
    | Float f -> "Float(" ^ string_of_float f ^ ")"
    | String s -> "String(" ^ s ^ ")"
    | Byte c -> "Byte(" ^ Char.escaped c ^ ")"
    | Bool b -> "Bool(" ^ string_of_bool b ^ ")"

    | EOF -> "<EOF>" 
end