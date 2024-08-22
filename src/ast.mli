type token =
  (* Operators *)
  | Plus
  | Minus
  | Star
  | Slash
  | Mod
  | Pow
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
  | Class
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
    | StringExpr of { value : string }
    | ByteExpr of { value : char }
    | VarExpr of string
    | BinaryExpr of { left : t; operator : token; right : t }
    | CallExpr of { callee : string; arguments : t list }
  [@@deriving show]
end

module Type : sig
  type t = SymbolType of { value : string } [@@deriving show]
end

module Stmt : sig
  type parameter = { name : string; param_type : Type.t } [@@deriving show]

  type t =
    | BlockStmt of { body : t list }
    | VarDeclarationStmt of {
        identifier : string;
        constant : bool;
        assigned_value : Expr.t option;
        explicit_type : Type.t;
      }
    | FunctionDeclStmt of {
        name : string;
        parameters : parameter list;
        return_type : Type.t option;
        body : t list;
      }
    | ReturnStmt of Expr.t
    | ExprStmt of Expr.t
    | IfStmt of { condition : Expr.t; then_branch : t; else_branch : t option }
  [@@deriving show]
end
