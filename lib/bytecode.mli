type opcode =
  | LOAD_INT of int
  | LOAD_FLOAT of float
  | LOAD_VAR of string
  | STORE_VAR of string
  | LOAD_STRING of string
  | LOAD_BYTE of char
  | LOAD_BOOL of bool
  | POW
  | MOD
  | CONCAT
  | FADD
  | FSUB
  | FMUL
  | FDIV
  | POP
  | HALT
  | RETURN
  | AND
  | OR
  | NOT
  | EQUAL
  | NOT_EQUAL
  | GREATER_EQUAL
  | LESS_EQUAL
  | GREATER
  | LESS
  | INC
  | DEC
  | JUMP of int
  | JUMP_IF_FALSE of int
  | PRINT
  | LEN

val pp_opcode : Format.formatter -> opcode -> unit
val compile_expr : Ast.Expr.t -> opcode list
val compile_stmt : Ast.Stmt.t -> opcode list
