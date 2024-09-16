open Syntax

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
  | PRINTLN
  | LEN
  | TOSTRING
  | TOINT
  | TOFLOAT

let pp_opcode fmt = function
  | LOAD_INT value -> Format.fprintf fmt "LOAD_INT %d" value
  | LOAD_FLOAT value -> Format.fprintf fmt "LOAD_FLOAT %f" value
  | LOAD_VAR name -> Format.fprintf fmt "LOAD_VAR %s" name
  | STORE_VAR name -> Format.fprintf fmt "STORE_VAR %s" name
  | LOAD_STRING value -> Format.fprintf fmt "LOAD_STRING %s" value
  | LOAD_BYTE value -> Format.fprintf fmt "LOAD_BYTE %c" value
  | LOAD_BOOL value -> Format.fprintf fmt "LOAD_BOOL %b" value
  | POW -> Format.fprintf fmt "POW"
  | MOD -> Format.fprintf fmt "MOD"
  | CONCAT -> Format.fprintf fmt "CONCAT"
  | FADD -> Format.fprintf fmt "FADD"
  | FSUB -> Format.fprintf fmt "FSUB"
  | FMUL -> Format.fprintf fmt "FMUL"
  | FDIV -> Format.fprintf fmt "FDIV"
  | POP -> Format.fprintf fmt "POP"
  | RETURN -> Format.fprintf fmt "RETURN"
  | HALT -> Format.fprintf fmt "HALT"
  | AND -> Format.fprintf fmt "AND"
  | OR -> Format.fprintf fmt "OR"
  | NOT -> Format.fprintf fmt "NOT"
  | EQUAL -> Format.fprintf fmt "EQUAL"
  | NOT_EQUAL -> Format.fprintf fmt "NOT_EQUAL"
  | GREATER_EQUAL -> Format.fprintf fmt "GREATER_EQUAL"
  | LESS_EQUAL -> Format.fprintf fmt "LESS_EQUAL"
  | GREATER -> Format.fprintf fmt "GREATER"
  | INC -> Format.fprintf fmt "INC"
  | DEC -> Format.fprintf fmt "DEC"
  | LESS -> Format.fprintf fmt "LESS"
  | JUMP label -> Format.fprintf fmt "JUMP %d" label
  | JUMP_IF_FALSE label -> Format.fprintf fmt "JUMP_IF_FALSE %d" label
  | PRINT -> Format.fprintf fmt "PRINT"
  | PRINTLN -> Format.fprintf fmt "PRINTLN"
  | LEN -> Format.fprintf fmt "LEN"
  | TOSTRING -> Format.fprintf fmt "TOSTRING"
  | TOINT -> Format.fprintf fmt "TOINT"
  | TOFLOAT -> Format.fprintf fmt "TOFLOAT"

let rec compile_expr = function
  | Ast.Expr.IntExpr { value } -> [ LOAD_INT value ]
  | Ast.Expr.FloatExpr { value } -> [ LOAD_FLOAT value ]
  | Ast.Expr.StringExpr { value } -> [ LOAD_STRING value ]
  | Ast.Expr.ByteExpr { value } -> [ LOAD_BYTE value ]
  | Ast.Expr.BoolExpr { value } ->
      if value then [ LOAD_BOOL true ] else [ LOAD_BOOL false ]
  | Ast.Expr.VarExpr name -> [ LOAD_VAR name ]
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
      | Ast.Carot -> left_bytecode @ right_bytecode @ [ CONCAT ]
      | Ast.LogicalAnd -> left_bytecode @ right_bytecode @ [ AND ]
      | Ast.LogicalOr -> left_bytecode @ right_bytecode @ [ OR ]
      | Ast.Greater -> left_bytecode @ right_bytecode @ [ GREATER ]
      | Ast.Less -> left_bytecode @ right_bytecode @ [ LESS ]
      | Ast.Eq -> left_bytecode @ right_bytecode @ [ EQUAL ]
      | Ast.Geq -> left_bytecode @ right_bytecode @ [ GREATER_EQUAL ]
      | Ast.Leq -> left_bytecode @ right_bytecode @ [ LESS_EQUAL ]
      | Ast.Neq -> left_bytecode @ right_bytecode @ [ NOT_EQUAL ]
      | _ -> failwith "ByteCode: Unsupported operator")
  | Ast.Expr.CallExpr { callee; arguments } -> (
      match callee with
      | Ast.Expr.VarExpr "print" ->
          let args_bytecode =
            List.fold_left (fun acc arg -> acc @ compile_expr arg) [] arguments
          in
          args_bytecode @ [ PRINT ]
      | Ast.Expr.VarExpr "println" ->
          let args_bytecode =
            List.fold_left (fun acc arg -> acc @ compile_expr arg) [] arguments
          in
          args_bytecode @ [ PRINTLN ]
      | Ast.Expr.VarExpr "len" ->
          let args_bytecode =
            List.fold_left (fun acc arg -> acc @ compile_expr arg) [] arguments
          in
          args_bytecode @ [ LEN ]
      | Ast.Expr.VarExpr "ToString" ->
          let args_bytecode =
            List.fold_left (fun acc arg -> acc @ compile_expr arg) [] arguments
          in
          args_bytecode @ [ TOSTRING ]
      | Ast.Expr.VarExpr "ToInt" ->
          let args_bytecode =
            List.fold_left (fun acc arg -> acc @ compile_expr arg) [] arguments
          in
          args_bytecode @ [ TOINT ]
      | Ast.Expr.VarExpr "ToFloat" ->
          let args_bytecode =
            List.fold_left (fun acc arg -> acc @ compile_expr arg) [] arguments
          in
          args_bytecode @ [ TOFLOAT ]
      | _ -> failwith "ByteCode: Unsupported function call")
  | Ast.Expr.UnaryExpr { operator; operand } -> (
      let operand_bytecode = compile_expr operand in
      match operator with
      | Ast.Not -> operand_bytecode @ [ NOT ]
      | Ast.Inc -> operand_bytecode @ [ INC ]
      | Ast.Dec -> operand_bytecode @ [ DEC ]
      | _ -> failwith "Unsupported unary operator")
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
        | stmt :: rest -> compile_stmt stmt @ compile_body rest
      in
      compile_body body
  | Ast.Stmt.ReturnStmt expr -> compile_expr expr @ [ RETURN ]
  | Ast.Stmt.IfStmt _ -> failwith "IfStmt not supported"
  | Ast.Stmt.ForStmt _ -> failwith "ForStmt not supported"
  | Ast.Stmt.VarDeclarationStmt
      { identifier; constant = _; assigned_value; explicit_type = _ } ->
      let expr_bytecode =
        match assigned_value with
        | Some expr -> compile_expr expr
        | None -> [ LOAD_INT 0 ]
      in
      expr_bytecode @ [ STORE_VAR identifier ]
  | Ast.Stmt.NewVarDeclarationStmt _ ->
      failwith "NewVarDeclarationStmt not supported"
  | Ast.Stmt.FunctionDeclStmt _ -> failwith "FunctionDeclStmt not supported"
  | Ast.Stmt.ClassDeclStmt _ -> failwith "ClassDeclStmt not supported"
  | Ast.Stmt.ImportStmt _ -> failwith "ImportStmt not supported"
  | Ast.Stmt.ExportStmt _ -> failwith "ExportStmt not supported"
  | Ast.Stmt.SwitchStmt _ -> failwith "SwitchStmt not supported"
  | Ast.Stmt.BreakStmt -> failwith "BreakStmt not supported"
