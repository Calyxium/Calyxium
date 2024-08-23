module TypeChecker = struct
  open Ast

  module Env = Map.Make(String)

  type func_sig = {
    param_types: Type.t list;
    return_type: Type.t;
  }

  type env = {
    var_type: Type.t Env.t;
    func_env: func_sig Env.t;
  }

  let empty_env = {
    var_type = Env.empty;
    func_env = Env.empty;
  }

  let lookup_var env name =
    try Env.find name env.var_type
    with Not_found -> failwith ("Unbound variable: " ^ name)

  let lookup_func env name =
    try Env.find name env.func_env
    with Not_found -> failwith ("Unbound function: " ^ name)

  let rec check_expr env = function
    | Expr.IntExpr _ -> Type.SymbolType { value = "int" }
    | Expr.FloatExpr _ -> Type.SymbolType { value = "float" }
    | Expr.StringExpr _ -> Type.SymbolType { value = "string" }
    | Expr.ByteExpr _ -> Type.SymbolType { value = "byte" }
    | Expr.BoolExpr _ -> Type.SymbolType { value = "bool" }
    | Expr.VarExpr name -> lookup_var env name
    | Expr.CallExpr { callee; arguments } ->
        let func_name = match callee with
          | Expr.VarExpr name -> name
          | _ -> failwith "Unsupported function call"
        in
        let { param_types; return_type } = lookup_func env func_name in
        if List.length arguments <> List.length param_types then
          failwith ("Incorrect number of arguments for function: " ^ func_name);
        List.iter2 (fun arg param_type ->
          let arg_type = check_expr env arg in
          if arg_type <> param_type then
            failwith ("Argument type mismatch in function call: " ^ func_name)
        ) arguments param_types;
        return_type
    | Expr.BinaryExpr { left; operator; right } ->
      let left_type = check_expr env left in
      let right_type = check_expr env right in
      (match operator with
       | Eq | Neq | Less | Greater | Leq | Geq ->
           if left_type = right_type then
             Type.SymbolType { value = "bool" }
           else
             failwith "Type mismatch in comparison expression"
       | PlusAssign | MinusAssign | StarAssign | SlashAssign ->
           failwith "Assignment operation cannot be used as a condition in an if statement"
       | Plus | Minus | Star | Slash | Mod | Pow ->
           if left_type = right_type then
             left_type
           else
             failwith "Type mismatch in arithmetic expression"
      | _ -> failwith "Unsupported operator in binary expression")
    | _ -> failwith "Unsupported expression"

  let check_var_decl env identifier explicit_type assigned_value =
    match assigned_value with
    | Some expr ->
        let value_type = check_expr env expr in
        if value_type = explicit_type then
          { env with var_type = Env.add identifier explicit_type env.var_type }
        else
          failwith ("Type mismatch in variable declaration: " ^ identifier)
    | None -> failwith ("Variable " ^ identifier ^ " has no value assigned")

  let rec check_func_decl env name parameters return_type body =
    let param_types = List.map (fun param -> param.Stmt.param_type) parameters in
    let var_env = List.fold_left (fun var_env param ->
      Env.add param.Stmt.name param.Stmt.param_type var_env
    ) env.var_type parameters in
    let func_sig = { param_types; return_type } in
    let func_env = Env.add name func_sig env.func_env in
    let new_env = { var_type = var_env; func_env } in
    let _ = check_block new_env body ~expected_return_type:(Some return_type) in
    { env with func_env }

  and check_stmt env ~expected_return_type = function
    | Stmt.VarDeclarationStmt { identifier; constant = _; assigned_value; explicit_type } ->
        check_var_decl env identifier explicit_type assigned_value
    | Stmt.FunctionDeclStmt { name; parameters; return_type; body } ->
        let return_type = match return_type with
          | Some t -> t
          | None -> failwith ("Function " ^ name ^ " must have a return type")
        in
        check_func_decl env name parameters return_type body
    | Stmt.BlockStmt { body } ->
        check_block env body ~expected_return_type
    | Stmt.ReturnStmt expr ->
        let return_type = check_expr env expr in
        (match expected_return_type with
        | Some expected_type ->
          if return_type <> expected_type then
            failwith ("Return type mismatch: expected " ^ (Type.show expected_type) ^ ", got " ^ (Type.show return_type))
          else env
        |None -> env)
    | Stmt.ExprStmt expr ->
      let _ = check_expr env expr in
      env
    | Stmt.IfStmt { condition; then_branch; else_branch } ->
      let cond_type = check_expr env condition in
      if cond_type <> Type.SymbolType { value = "bool" } then
        failwith "Condition in if statement must be a boolean"
      else
        let env_then = check_stmt env ~expected_return_type then_branch in
        let env_final = match else_branch with
          | Some else_branch -> check_stmt env_then ~expected_return_type else_branch
          | None -> env_then
        in
        env_final
    | _ -> failwith "Unsupported statement"

    and check_block env stmts ~expected_return_type =
      List.fold_left (fun env stmt -> check_stmt env stmt ~expected_return_type) env stmts
    
end
