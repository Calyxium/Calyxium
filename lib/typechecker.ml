module TypeChecker = struct
  open Ast
  module Env = Map.Make (String)

  type func_sig = { param_types : Type.t list; return_type : Type.t }
  type class_info = { class_type : Type.t; properties : (string * Type.t) list }

  type env = {
    var_type : Type.t Env.t;
    func_env : func_sig Env.t;
    class_env : class_info Env.t;
    modules : string list;
    exports : string list;
  }

  let empty_env =
    {
      var_type = Env.empty;
      func_env = Env.empty;
      class_env = Env.empty;
      modules = [];
      exports = [];
    }

  let lookup_var env name =
    try Env.find name env.var_type
    with Not_found -> failwith ("Unbound variable: " ^ name)

  let lookup_func env name =
    try Env.find name env.func_env
    with Not_found -> failwith ("Unbound function: " ^ name)

  let lookup_class env name =
    try Env.find name env.class_env
    with Not_found -> failwith ("Unbound class: " ^ name)

  let check_import env module_name =
    if List.mem module_name env.modules then
      failwith ("Module " ^ module_name ^ " already imported")
    else { env with modules = module_name :: env.modules }

  let check_export env identifier =
    if Env.mem identifier env.var_type then
      { env with exports = identifier :: env.exports }
    else failwith ("Cannot export undefined identifier: " ^ identifier)

  let rec check_expr env = function
    | Expr.IntExpr _ -> Type.SymbolType { value = "int" }
    | Expr.FloatExpr _ -> Type.SymbolType { value = "float" }
    | Expr.StringExpr _ -> Type.SymbolType { value = "string" }
    | Expr.ByteExpr _ -> Type.SymbolType { value = "byte" }
    | Expr.BoolExpr _ -> Type.SymbolType { value = "bool" }
    | Expr.VarExpr "true" | Expr.VarExpr "false" ->
        Type.SymbolType { value = "bool" }
    | Expr.VarExpr name -> lookup_var env name
    | Expr.ArrayExpr { elements } -> (
        match elements with
        | [] -> failwith "Cannot infer type of an empty array"
        | first_elem :: _ ->
            let elem_type = check_expr env first_elem in
            List.iter
              (fun elem ->
                let t = check_expr env elem in
                if t <> elem_type then
                  failwith "Type mismatch in array elements")
              elements;
            Type.ArrayType { element_type = elem_type })
    | Expr.IndexExpr { array; index } -> (
        let array_type = check_expr env array in
        let index_type = check_expr env index in
        if index_type <> Type.SymbolType { value = "int" } then
          failwith "Array index must be an integer";
        match array_type with
        | Type.ArrayType { element_type } -> element_type
        | _ -> failwith "Cannot index non-array type")
    | Expr.SliceExpr { array; start; end_ } ->
        let array_type = check_expr env array in
        let start_type = check_expr env start in
        let end_type = check_expr env end_ in
        if
          start_type <> Type.SymbolType { value = "int" }
          || end_type <> Type.SymbolType { value = "int" }
        then failwith "Array slice indices must be integers";
        array_type
    | Expr.CallExpr { callee; arguments } ->
        let func_name =
          match callee with
          | Expr.VarExpr name -> name
          | _ -> failwith "Unsupported function call"
        in
        let { param_types; return_type } = lookup_func env func_name in
        if List.length arguments <> List.length param_types then
          failwith ("Incorrect number of arguments for function: " ^ func_name);
        List.iter2
          (fun arg param_type ->
            let arg_type = check_expr env arg in
            if arg_type <> param_type then
              failwith ("Argument type mismatch in function call: " ^ func_name))
          arguments param_types;
        return_type
    | Expr.BinaryExpr { left; operator; right } -> (
        let left_type = check_expr env left in
        let right_type = check_expr env right in
        match operator with
        | Assign -> (
            match left with
            | Expr.PropertyAccessExpr { object_name; property_name } -> (
                let obj_type = check_expr env object_name in
                match obj_type with
                | Type.ClassType { properties; _ } -> (
                    try
                      let expected_type = List.assoc property_name properties in
                      if expected_type <> right_type then
                        failwith
                          ("Type mismatch in assignment to property "
                         ^ property_name)
                      else left_type
                    with Not_found ->
                      failwith ("Undefined property: " ^ property_name))
                | _ -> failwith "Assignment to non-object property")
            | Expr.VarExpr name ->
                let var_type = lookup_var env name in
                if var_type <> right_type then
                  failwith ("Type mismatch in assignment to variable " ^ name)
                else var_type
            | _ -> failwith "Invalid left-hand side in assignment")
        | Eq | Neq | Less | Greater | Leq | Geq ->
            if left_type = right_type then Type.SymbolType { value = "bool" }
            else failwith "Type mismatch in comparison expression"
        | Plus | Minus | Star | Slash | Mod | Pow ->
            if left_type = right_type then left_type
            else failwith "Type mismatch in arithmetic expression"
        | PlusAssign | MinusAssign | StarAssign | SlashAssign ->
            failwith
              "Assignment operation cannot be used as a condition in an if \
               statement"
        | _ -> failwith "Unsupported operator in binary expression")
    | Expr.PropertyAccessExpr { object_name; property_name } -> (
        let obj_type = check_expr env object_name in
        match obj_type with
        | Type.ClassType { properties; _ } -> (
            try List.assoc property_name properties
            with Not_found -> failwith ("Undefined property: " ^ property_name))
        | _ -> failwith "Property access on non-object type")
    | expr ->
        failwith ("Unsupported expression: " ^ (Expr.show expr))

  let check_var_decl env identifier explicit_type assigned_value =
    match assigned_value with
    | Some expr ->
        let value_type = check_expr env expr in
        if value_type = explicit_type then
          { env with var_type = Env.add identifier explicit_type env.var_type }
        else failwith ("Type mismatch in variable declaration: " ^ identifier)
    | None -> failwith ("Variable " ^ identifier ^ " has no value assigned")

  let rec check_func_decl env name parameters return_type body =
    let param_types =
      List.map (fun param -> param.Stmt.param_type) parameters
    in
    let var_env =
      List.fold_left
        (fun var_env param ->
          Env.add param.Stmt.name param.Stmt.param_type var_env)
        env.var_type parameters
    in
    let func_sig = { param_types; return_type } in
    let func_env = Env.add name func_sig env.func_env in
    let new_env =
      {
        var_type = var_env;
        func_env;
        class_env = env.class_env;
        modules = env.modules;
        exports = env.exports;
      }
    in
    let _ = check_block new_env body ~expected_return_type:(Some return_type) in
    { env with func_env }

  and check_stmt env ~expected_return_type = function
    | Stmt.VarDeclarationStmt
        { identifier; constant = _; assigned_value; explicit_type } ->
        check_var_decl env identifier explicit_type assigned_value
    | Stmt.NewVarDeclarationStmt
        { identifier; constant = _; assigned_value; arguments } ->
        let class_name =
          match assigned_value with
          | Some (Expr.NewExpr { class_name; _ }) -> class_name
          | _ ->
              failwith
                ("Expected a class instantiation for variable: " ^ identifier)
        in
        let class_info = lookup_class env class_name in

        if
          List.length arguments > 0
          && List.length arguments <> List.length class_info.properties
        then
          failwith
            ("Incorrect number of arguments for class instantiation: "
           ^ identifier);

        if List.length arguments > 0 then
          List.iter2
            (fun arg (prop_name, prop_type) ->
              let arg_type = check_expr env arg in
              if arg_type <> prop_type then
                failwith
                  ("Type mismatch for property " ^ prop_name ^ " in class "
                 ^ class_name))
            arguments class_info.properties;

        {
          env with
          var_type = Env.add identifier class_info.class_type env.var_type;
        }
    | Stmt.FunctionDeclStmt { name; parameters; return_type; body } ->
        let return_type =
          match return_type with
          | Some t -> t
          | None -> failwith ("Function " ^ name ^ " must have a return type")
        in
        check_func_decl env name parameters return_type body
    | Stmt.ClassDeclStmt { name; properties; methods = _ } ->
        let prop_list =
          List.map (fun param -> (param.Stmt.name, param.param_type)) properties
        in
        let class_info =
          {
            class_type = Type.ClassType { name; properties = prop_list };
            properties = prop_list;
          }
        in
        let class_env = Env.add name class_info env.class_env in
        { env with class_env }
    | Stmt.BlockStmt { body } -> check_block env body ~expected_return_type
    | Stmt.ReturnStmt expr -> (
        let return_type = check_expr env expr in
        match expected_return_type with
        | Some expected_type ->
            if return_type <> expected_type then
              failwith
                ("Return type mismatch: expected " ^ Type.show expected_type
               ^ ", got " ^ Type.show return_type)
            else env
        | None -> env)
    | Stmt.ExprStmt expr ->
        let _ = check_expr env expr in
        env
    | Stmt.IfStmt { condition; then_branch; else_branch } ->
        let cond_type = check_expr env condition in
        if cond_type <> Type.SymbolType { value = "bool" } then
          failwith "Condition in if statement must be a boolean"
        else
          let env_then = check_stmt env ~expected_return_type then_branch in
          let env_final =
            match else_branch with
            | Some else_branch ->
                check_stmt env_then ~expected_return_type else_branch
            | None -> env_then
          in
          env_final
    | Stmt.ForStmt { init; condition; increment; body } ->
        let env =
          match init with
          | Some stmt -> check_stmt env ~expected_return_type:None stmt
          | None -> env
        in
        let _ =
          let cond_type = check_expr env condition in
          if cond_type <> Type.SymbolType { value = "bool" } then
            failwith "Condition in for statement must be a boolean"
        in
        let env =
          match increment with
          | Some stmt -> check_stmt env ~expected_return_type:None stmt
          | None -> env
        in
        check_block env [ body ] ~expected_return_type
    | Stmt.SwitchStmt { expr; cases; default_case } ->
        let switch_type = check_expr env expr in
        List.iter
          (fun (case_expr, case_body) ->
            let case_type = check_expr env case_expr in
            if case_type <> switch_type then
              failwith "Case expression type does not match switch expression";
            ignore (check_block env case_body ~expected_return_type))
          cases;
        (match default_case with
        | Some body -> ignore (check_block env body ~expected_return_type)
        | None -> ());
        env
    | Stmt.ImportStmt { module_name } -> check_import env module_name
    | Stmt.ExportStmt { identifier } -> check_export env identifier
    | stmt ->
        failwith ("Unsupported statement: " ^ (Stmt.show stmt))

  and check_block env stmts ~expected_return_type =
    List.fold_left
      (fun env stmt -> check_stmt env stmt ~expected_return_type)
      env stmts
end
