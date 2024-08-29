open Ast

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

let pp_opcode fmt = function
  | LOAD_INT value -> Format.fprintf fmt "LOAD_INT %d" value
  | LOAD_FLOAT value -> Format.fprintf fmt "LOAD_FLOAT %f" value
  | MOD -> Format.fprintf fmt "MOD"
  | FADD -> Format.fprintf fmt "FADD"
  | FSUB -> Format.fprintf fmt "FSUB"
  | FMUL -> Format.fprintf fmt "FMUL"
  | FDIV -> Format.fprintf fmt "FDIV"
  | POP -> Format.fprintf fmt "POP"
  | RETURN -> Format.fprintf fmt "RETURN"
  | HALT -> Format.fprintf fmt "HALT"


let rec compile_expr = function
  | Expr.IntExpr { value } -> [LOAD_INT value]
  | Expr.FloatExpr { value } -> [LOAD_FLOAT value]
  | Expr.BinaryExpr { left; operator; right } ->
      let left_bytecode = compile_expr left in
      let right_bytecode = compile_expr right in
      begin
        match operator with
        | Plus | Minus ->
            let compiled_right =
              match right with
              | Expr.BinaryExpr { operator = Star | Slash | Mod; _ } ->
                  compile_expr right
              | _ -> right_bytecode
            in
            left_bytecode @ compiled_right @ (match operator with
            | Plus -> [FADD]
            | Minus -> [FSUB]
            | _ -> failwith "Unsupported operator")
        | Star | Slash | Mod ->
            left_bytecode @ right_bytecode @ (match operator with
            | Star -> [FMUL]
            | Slash -> [FDIV]
            | Mod -> [MOD]
            | _ -> failwith "Unsupported operator")
        | _ -> failwith "Unsupported operator"
      end
  | _ -> failwith "Unsupported expression"


let rec compile_stmt = function
  | Ast.Stmt.ExprStmt expr -> compile_expr expr (* Do not add POP here *)
  | Ast.Stmt.BlockStmt { body } ->
      let rec compile_body = function
        | [] -> []
        | [stmt] -> compile_stmt stmt (* Last statement, don't pop *)
        | stmt :: rest -> compile_stmt stmt @ [POP] @ compile_body rest
      in
      compile_body body
  | Ast.Stmt.ReturnStmt expr -> compile_expr expr @ [RETURN]
  | _ -> failwith "Unsupported statement"

