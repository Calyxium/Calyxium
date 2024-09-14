let rec execute_bytecode instructions stack env pc =
  if pc >= Array.length instructions then
    match stack with [] -> 0.0 | hd :: _ -> hd
  else
    match instructions.(pc) with
    | Bytecode.LOAD_INT value ->
        execute_bytecode instructions (float_of_int value :: stack) env (pc + 1)
    | Bytecode.LOAD_FLOAT value ->
        execute_bytecode instructions (value :: stack) env (pc + 1)
    | Bytecode.LOAD_VAR name ->
        let value =
          try List.assoc name env
          with Not_found -> failwith ("Error: Variable " ^ name ^ " not found")
        in
        execute_bytecode instructions (value :: stack) env (pc + 1)
    | Bytecode.STORE_VAR name -> (
        match stack with
        | [] -> failwith "Error: Stack is empty when trying to store variable"
        | value :: rest ->
            let env = (name, value) :: List.remove_assoc name env in
            execute_bytecode instructions rest env (pc + 1))
    | Bytecode.FADD -> (
        match stack with
        | a :: b :: rest ->
            execute_bytecode instructions ((b +. a) :: rest) env (pc + 1)
        | _ -> failwith "Error: Stack underflow during FADD")
    | Bytecode.FSUB -> (
        match stack with
        | a :: b :: rest ->
            execute_bytecode instructions ((b -. a) :: rest) env (pc + 1)
        | _ -> failwith "Error: Stack underflow during FSUB")
    | Bytecode.FMUL -> (
        match stack with
        | a :: b :: rest ->
            execute_bytecode instructions ((b *. a) :: rest) env (pc + 1)
        | _ -> failwith "Error: Stack underflow during FMUL")
    | Bytecode.FDIV -> (
        match stack with
        | a :: b :: rest ->
            if a = 0. then failwith "Error: Division by zero"
            else execute_bytecode instructions ((b /. a) :: rest) env (pc + 1)
        | _ -> failwith "Error: Stack underflow during FDIV")
    | Bytecode.MOD -> (
        match stack with
        | a :: b :: rest ->
            execute_bytecode instructions (mod_float b a :: rest) env (pc + 1)
        | _ -> failwith "Error: Stack underflow during MOD")
    | Bytecode.POW -> (
        match stack with
        | a :: b :: rest ->
            execute_bytecode instructions ((b ** a) :: rest) env (pc + 1)
        | _ -> failwith "Error: Stack underflow during POW")
    | Bytecode.POP -> (
        match stack with
        | [] -> failwith "Error: Stack is empty during POP"
        | _ :: rest -> execute_bytecode instructions rest env (pc + 1))
    | Bytecode.RETURN -> (
        match stack with
        | [] -> failwith "Error: Stack is empty during RETURN"
        | hd :: _ -> hd)
    | Bytecode.HALT -> (
        match stack with
        | [] -> failwith "Error: Stack is empty during HALT"
        | hd :: _ -> hd)

let run instructions =
  try execute_bytecode (Array.of_list instructions) [] [] 0
  with Failure msg -> failwith ("Runtime error: " ^ msg)
