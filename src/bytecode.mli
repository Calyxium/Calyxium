type opcode =
  | LOAD_INT of int
  | LOAD_FLOAT of float
  | MOD
  | FADD
  | FSUB
  | FMUL
  | FDIV
  | POP
  | HALT
  | RETURN

val pp_opcode : Format.formatter -> opcode -> unit
val compile_expr : Ast.Expr.t -> opcode list
val compile_stmt : Ast.Stmt.t -> opcode list
