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
  | New
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

let pp_token fmt = function
  | Plus -> Format.fprintf fmt "Plus"
  | Minus -> Format.fprintf fmt "Minus"
  | Star -> Format.fprintf fmt "Star"
  | Slash -> Format.fprintf fmt "Slash"
  | LParen -> Format.fprintf fmt "LParen"
  | RParen -> Format.fprintf fmt "RParen"
  | LBracket -> Format.fprintf fmt "LBracket"
  | RBracket -> Format.fprintf fmt "RBracket"
  | LBrace -> Format.fprintf fmt "LBrace"
  | RBrace -> Format.fprintf fmt "RBrace"
  | Dot -> Format.fprintf fmt "Dot"
  | Question -> Format.fprintf fmt "Question"
  | Colon -> Format.fprintf fmt "Colon"
  | Semi -> Format.fprintf fmt "Semi"
  | Comma -> Format.fprintf fmt "Comma"
  | Not -> Format.fprintf fmt "Not"
  | Pipe -> Format.fprintf fmt "Pipe"
  | Amspersand -> Format.fprintf fmt "Amspersand"
  | Greater -> Format.fprintf fmt "Greater"
  | Less -> Format.fprintf fmt "Less"
  | LogicalOr -> Format.fprintf fmt "LogicalOr"
  | LogicalAnd -> Format.fprintf fmt "LogicalAnd"
  | Eq -> Format.fprintf fmt "Eq"
  | Neq -> Format.fprintf fmt "Neq"
  | Geq -> Format.fprintf fmt "Geq"
  | Leq -> Format.fprintf fmt "Leq"
  | Assign -> Format.fprintf fmt "Assign"
  | PlusAssign -> Format.fprintf fmt "PlusAssign"
  | MinusAssign -> Format.fprintf fmt "MinusAssign"
  | StarAssign -> Format.fprintf fmt "StarAssign"
  | SlashAssign -> Format.fprintf fmt "SlashAssign"
  | Function -> Format.fprintf fmt "Function"
  | If -> Format.fprintf fmt "If"
  | Else -> Format.fprintf fmt "Else"
  | Return -> Format.fprintf fmt "Return"
  | Var -> Format.fprintf fmt "Var"
  | Const -> Format.fprintf fmt "Const"
  | Switch -> Format.fprintf fmt "Switch"
  | Case -> Format.fprintf fmt "Case"
  | Break -> Format.fprintf fmt "Break"
  | Default -> Format.fprintf fmt "Default"
  | For -> Format.fprintf fmt "For"
  | True -> Format.fprintf fmt "True"
  | False -> Format.fprintf fmt "False"
  | Try -> Format.fprintf fmt "Try"
  | Catch -> Format.fprintf fmt "Catch"
  | Import -> Format.fprintf fmt "Import"
  | Export -> Format.fprintf fmt "Export"
  | This -> Format.fprintf fmt "This"
  | New -> Format.fprintf fmt "New"
  | Null -> Format.fprintf fmt "Null"
  | IntType -> Format.fprintf fmt "IntType"
  | FloatType -> Format.fprintf fmt "FloatType"
  | StringType -> Format.fprintf fmt "StringType"
  | ByteType -> Format.fprintf fmt "ByteType"
  | BoolType -> Format.fprintf fmt "BoolType"
  | Ident s -> Format.fprintf fmt "Ident(%s)" s
  | Int i -> Format.fprintf fmt "Int(%d)" i
  | Float f -> Format.fprintf fmt "Float(%f)" f
  | String s -> Format.fprintf fmt "String(%s)" s
  | Byte c -> Format.fprintf fmt "Byte(%c)" c
  | Bool b -> Format.fprintf fmt "Bool(%b)" b
  | EOF -> Format.fprintf fmt "EOF"

module Type = struct
  type t = SymbolType of { value : string } [@@deriving show]
end

module Expr = struct
  type t =
    | IntExpr of { value : int }
    | FloatExpr of { value : float }
    | VarExpr of string
    | BinaryExpr of { left : t; operator : token; right : t }
  [@@deriving show]
end

module Stmt = struct
  type t =
    | BlockStmt of { body : t list }
    | VarDeclarationStmt of {
        identifier : string;
        constant : bool;
        assigned_value : Expr.t option;
        explicit_type : Type.t;
      }
    | ExprStmt of Expr.t
  [@@deriving show]
end
