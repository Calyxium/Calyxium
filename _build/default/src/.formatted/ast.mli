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

module Expr : sig
  module NoBinOP : sig
    type t =
      | Int of int
      | Float of float
      | BinOp of token * t * t (* Include BinOp here *)
      | BinList of t * (token * t) list

    val reduce : t -> (token * t) list -> t
  end

  type t =
    | Int of int
    | Float of float
    | BinOp of token * t * t (* Represents a binary operation *)
    | VarDecl of string * token * t option (* Represents `let x: int = 10` *)

  val of_no_binop : NoBinOP.t -> t
  val to_string : t -> string
end
