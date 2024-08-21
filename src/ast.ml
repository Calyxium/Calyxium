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

  module Expr = struct
    module NoBinOP = struct
      type t =
        | Int of int
        | Float of float
        | BinOp of token * t * t
        | BinList of t * (token * t) list
      
      (* Helper function to reduce BinList into a single BinOp expression *)
      let rec reduce first rest : t = 
        match rest with
        | [] -> first
        | (op, next_expr) :: tail ->
            let lhs = first in
            let rhs = next_expr in
            reduce (BinOp (op, lhs, rhs)) tail
    end
    
    type t =
      | Int of int
      | Float of float
      | BinOp of token * t * t  (* Represents a binary operation *)
  
    (* Function to convert NoBinOP.t to Expr.t *)
    let rec of_no_binop (no_binop_expr: NoBinOP.t) : t =
      match no_binop_expr with
      | NoBinOP.Int i -> Int i
      | NoBinOP.Float f -> Float f
      | NoBinOP.BinOp (op, lhs, rhs) -> BinOp (op, of_no_binop lhs, of_no_binop rhs)
      | NoBinOP.BinList (first, rest) ->
          (* Convert the result of `NoBinOP.reduce` from `NoBinOP.t` to `Expr.t` *)
          of_no_binop (NoBinOP.reduce first rest)
  
    let rec to_string expr =
      match expr with
      | Int i -> string_of_int i
      | Float f -> string_of_float f
      | BinOp (op, lhs, rhs) ->
        let op_str = match op with
          | Plus -> "+"
          | Minus -> "-"
          | Star -> "*"
          | Slash -> "/"
          | _ -> "?"
        in
        Printf.sprintf "(%s %s %s)" (to_string lhs) op_str (to_string rhs)
  end
  