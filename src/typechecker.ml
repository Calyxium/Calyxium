module TypeChecker = struct
  open Ast

  module Env = Map.Make(String)

  type env = Type.t Env.t

  let lookup env name =
    try Env.find name env
    with Not_found -> failwith ("Unbound variable: " ^ name)

  let check_expr env = function
    | Expr.IntExpr _ -> Type.SymbolType { value = "int" }
    | Expr.FloatExpr _ -> Type.SymbolType { value = "float" }
    | Expr.StringExpr _ -> Type.SymbolType { value = "string" }
    | Expr.ByteExpr _ -> Type.SymbolType { value = "byte" }
    | Expr.VarExpr name -> lookup env name
    | _ -> failwith "Unsupported expression"

  let check_var_decl env identifier explicit_type assigned_value =
    match assigned_value with
    | Some expr ->
        let value_type = check_expr env expr in
        if value_type = explicit_type then
          Env.add identifier explicit_type env
        else
          failwith ("Type mismatch in variable declaration: " ^ identifier)
    | None -> failwith ("Variable " ^ identifier ^ " has no value assigned")

  (* Check a statement *)
  let rec check_stmt env = function
    | Stmt.VarDeclarationStmt { identifier; constant = _; assigned_value; explicit_type } ->
        check_var_decl env identifier explicit_type assigned_value
    | Stmt.BlockStmt { body } ->
        check_block env body
    | _ -> failwith "Unsupported statement"

  and check_block env stmts =
    List.fold_left (fun env stmt -> check_stmt env stmt) env stmts
end
