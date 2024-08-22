
(* The type of tokens. *)

type token = 
  | Var
  | Try
  | True
  | This
  | Switch
  | StringType
  | String of (string)
  | StarAssign
  | Star
  | SlashAssign
  | Slash
  | Semi
  | Return
  | RParen
  | RBracket
  | RBrace
  | Question
  | PlusAssign
  | Plus
  | Pipe
  | Null
  | Not
  | New
  | Neq
  | MinusAssign
  | Minus
  | LogicalOr
  | LogicalAnd
  | Less
  | Leq
  | LParen
  | LBracket
  | LBrace
  | IntType
  | Int of (int)
  | Import
  | If
  | Ident of (string)
  | Greater
  | Geq
  | Function
  | For
  | FloatType
  | Float of (float)
  | False
  | Export
  | Eq
  | Else
  | EOF
  | Dot
  | Default
  | Const
  | Comma
  | Colon
  | Catch
  | Case
  | ByteType
  | Byte of (char)
  | Break
  | BoolType
  | Bool of (bool)
  | Assign
  | Amspersand

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val program: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ast.Expr.t list)
