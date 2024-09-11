type opcode =
  | LOAD_INT of int
  | LOAD_FLOAT of float
  | POW
  | MOD
  | FADD
  | FSUB
  | FMUL
  | FDIV
  | POP
  | HALT
  | RETURN

let pp_opcode fmt = function
  | LOAD_INT value -> Format.fprintf fmt "LOAD_INT %d" value
  | LOAD_FLOAT value -> Format.fprintf fmt "LOAD_FLOAT %f" value
  | POW -> Format.fprintf fmt "POW"
  | MOD -> Format.fprintf fmt "MOD"
  | FADD -> Format.fprintf fmt "FADD"
  | FSUB -> Format.fprintf fmt "FSUB"
  | FMUL -> Format.fprintf fmt "FMUL"
  | FDIV -> Format.fprintf fmt "FDIV"
  | POP -> Format.fprintf fmt "POP"
  | RETURN -> Format.fprintf fmt "RETURN"
  | HALT -> Format.fprintf fmt "HALT"

let rec compile_expr = function
  | Ast.Expr.IntExpr { value } -> [ LOAD_INT value ]
  | Ast.Expr.FloatExpr { value } -> [ LOAD_FLOAT value ]
  | Ast.Expr.StringExpr _ -> failwith "StringExpr not supported"
  | Ast.Expr.ByteExpr _ -> failwith "ByteExpr not supported"
  | Ast.Expr.BoolExpr _ -> failwith "BoolExpr not supported"
  | Ast.Expr.VarExpr _ -> failwith "VarExpr not supported"
  | Ast.Expr.BinaryExpr { left; operator; right } -> (
      let left_bytecode = compile_expr left in
      let right_bytecode = compile_expr right in
      match operator with
      | Ast.Plus -> left_bytecode @ right_bytecode @ [ FADD ]
      | Ast.Minus -> left_bytecode @ right_bytecode @ [ FSUB ]
      | Ast.Star -> left_bytecode @ right_bytecode @ [ FMUL ]
      | Ast.Slash -> left_bytecode @ right_bytecode @ [ FDIV ]
      | Ast.Mod -> left_bytecode @ right_bytecode @ [ MOD ]
      | Ast.Pow -> left_bytecode @ right_bytecode @ [ POW ]
      | _ -> failwith "Unsupported operator")
  | Ast.Expr.CallExpr _ -> failwith "CallExpr not supported"
  | Ast.Expr.UnaryExpr _ -> failwith "UnaryExpr not supported"
  | Ast.Expr.NullExpr -> failwith "NullExpr not supported"
  | Ast.Expr.NewExpr _ -> failwith "NewExpr not supported"
  | Ast.Expr.PropertyAccessExpr _ -> failwith "PropertyAccessExpr not supported"
  | Ast.Expr.ArrayExpr _ -> failwith "ArrayExpr not supported"
  | Ast.Expr.IndexExpr _ -> failwith "IndexExpr not supported"
  | Ast.Expr.SliceExpr _ -> failwith "SliceExpr not supported"

let rec compile_stmt = function
  | Ast.Stmt.ExprStmt expr -> compile_expr expr
  | Ast.Stmt.BlockStmt { body } ->
      let rec compile_body = function
        | [] -> []
        | [ stmt ] -> compile_stmt stmt
        | stmt :: rest -> compile_stmt stmt @ [ POP ] @ compile_body rest
      in
      compile_body body
  | Ast.Stmt.ReturnStmt expr -> compile_expr expr @ [ RETURN ]
  | Ast.Stmt.IfStmt _ -> failwith "IfStmt not supported"
  | Ast.Stmt.ForStmt _ -> failwith "ForStmt not supported"
  | Ast.Stmt.VarDeclarationStmt _ -> failwith "VarDeclarationStmt not supported"
  | Ast.Stmt.NewVarDeclarationStmt _ ->
      failwith "NewVarDeclarationStmt not supported"
  | Ast.Stmt.FunctionDeclStmt _ -> failwith "FunctionDeclStmt not supported"
  | Ast.Stmt.ClassDeclStmt _ -> failwith "ClassDeclStmt not supported"
  | Ast.Stmt.ImportStmt _ -> failwith "ImportStmt not supported"
  | Ast.Stmt.ExportStmt _ -> failwith "ExportStmt not supported"
  | Ast.Stmt.SwitchStmt _ -> failwith "SwitchStmt not supported"
  | Ast.Stmt.BreakStmt -> failwith "BreakStmt not supported"
