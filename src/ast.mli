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

val pp_token : Format.formatter -> token -> unit

module Expr : sig
  type t =
    | IntExpr of { value : int }
    | FloatExpr of { value : float }
    | VarExpr of string
    | BinaryExpr of { left : t; operator : token; right : t }
  [@@deriving show]
end

module Type : sig
  type t = SymbolType of { value : string } [@@deriving show]
end

module Stmt : sig
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
