module Token : sig
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

    val string_of_token : token -> string
end