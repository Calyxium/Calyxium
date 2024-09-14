let string_table = Hashtbl.create 10

let add_string str =
  let id = Hashtbl.hash str in
  Hashtbl.add string_table id str;
  id

let replace_newline str =
  let buffer = Buffer.create (String.length str) in
  let rec process_chars i =
    if i < String.length str then
      if i < String.length str - 1 && str.[i] = '\\' && str.[i + 1] = 'n' then (
        Buffer.add_char buffer '\n';
        process_chars (i + 2) (* Skip the next 'n' *))
      else (
        Buffer.add_char buffer str.[i];
        process_chars (i + 1))
  in
  process_chars 0;
  Buffer.contents buffer

let rec execute_bytecode instructions stack env pc =
  if pc >= Array.length instructions then
    match stack with [] -> 0.0 | hd :: _ -> hd
  else
    match instructions.(pc) with
    | Bytecode.LOAD_INT value ->
        execute_bytecode instructions (float_of_int value :: stack) env (pc + 1)
    | Bytecode.LOAD_FLOAT value ->
        execute_bytecode instructions (value :: stack) env (pc + 1)
    | Bytecode.LOAD_STRING value ->
        let id = Hashtbl.hash value in
        Hashtbl.add string_table id value;
        execute_bytecode instructions (float_of_int id :: stack) env (pc + 1)
    | Bytecode.LOAD_BYTE value ->
        let id = Hashtbl.hash (String.make 1 value) in
        Hashtbl.add string_table id (String.make 1 value);
        execute_bytecode instructions (float_of_int id :: stack) env (pc + 1)
    | Bytecode.LOAD_BOOL value ->
        execute_bytecode instructions
          ((if value then 1.0 else 0.0) :: stack)
          env (pc + 1)
    | Bytecode.LOAD_VAR name ->
        let value =
          try List.assoc name env
          with Not_found ->
            failwith ("Runtime Error: Variable " ^ name ^ " not found")
        in
        execute_bytecode instructions (value :: stack) env (pc + 1)
    | Bytecode.STORE_VAR name -> (
        match stack with
        | [] ->
            failwith
              "Runtime Error: Stack is empty when trying to store variable"
        | value :: rest ->
            let env = (name, value) :: List.remove_assoc name env in
            execute_bytecode instructions rest env (pc + 1))
    | Bytecode.FADD -> (
        match stack with
        | a :: b :: rest ->
            execute_bytecode instructions ((b +. a) :: rest) env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during FADD")
    | Bytecode.FSUB -> (
        match stack with
        | a :: b :: rest ->
            execute_bytecode instructions ((b -. a) :: rest) env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during FSUB")
    | Bytecode.FMUL -> (
        match stack with
        | a :: b :: rest ->
            execute_bytecode instructions ((b *. a) :: rest) env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during FMUL")
    | Bytecode.FDIV -> (
        match stack with
        | a :: b :: rest ->
            if a = 0. then failwith "Runtime Error: Division by zero"
            else execute_bytecode instructions ((b /. a) :: rest) env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during FDIV")
    | Bytecode.MOD -> (
        match stack with
        | a :: b :: rest ->
            execute_bytecode instructions (mod_float b a :: rest) env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during MOD")
    | Bytecode.POW -> (
        match stack with
        | a :: b :: rest ->
            execute_bytecode instructions ((b ** a) :: rest) env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during POW")
    | Bytecode.POP -> (
        match stack with
        | [] -> failwith "Runtime Error: Stack is empty during POP"
        | _ :: rest -> execute_bytecode instructions rest env (pc + 1))
    | Bytecode.AND -> (
        match stack with
        | a :: b :: rest ->
            let result = if b <> 0.0 && a <> 0.0 then 1.0 else 0.0 in
            execute_bytecode instructions (result :: rest) env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during AND")
    | Bytecode.OR -> (
        match stack with
        | a :: b :: rest ->
            let result = if b <> 0.0 || a <> 0.0 then 1.0 else 0.0 in
            execute_bytecode instructions (result :: rest) env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during OR")
    | Bytecode.NOT -> (
        match stack with
        | a :: rest ->
            let result = if a = 0.0 then 1.0 else 0.0 in
            execute_bytecode instructions (result :: rest) env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during NOT")
    | Bytecode.INC -> (
        match stack with
        | a :: rest ->
            let result = a +. 1.0 in
            execute_bytecode instructions (result :: rest) env (pc + 1)
        | [] -> failwith "Stack underflow: no value to increment")
    | Bytecode.DEC -> (
        match stack with
        | a :: rest ->
            let result = a -. 1.0 in
            execute_bytecode instructions (result :: rest) env (pc + 1)
        | [] -> failwith "Stack underflow: no value to decrement")
    | Bytecode.GREATER -> (
        match stack with
        | a :: b :: rest ->
            let result = if b <> 0.0 > (a <> 0.0) then 1.0 else 0.0 in
            execute_bytecode instructions (result :: rest) env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during GREATER")
    | Bytecode.LESS -> (
        match stack with
        | a :: b :: rest ->
            let result = if b <> 0.0 < (a <> 0.0) then 1.0 else 0.0 in
            execute_bytecode instructions (result :: rest) env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during LESS")
    | Bytecode.EQUAL -> (
        match stack with
        | a :: b :: rest ->
            let result = if b <> 0.0 == (a <> 0.0) then 1.0 else 0.0 in
            execute_bytecode instructions (result :: rest) env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during EQUAL")
    | Bytecode.GREATER_EQUAL -> (
        match stack with
        | a :: b :: rest ->
            let result = if b <> 0.0 >= (a <> 0.0) then 1.0 else 0.0 in
            execute_bytecode instructions (result :: rest) env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during GREATER_EQUAL")
    | Bytecode.LESS_EQUAL -> (
        match stack with
        | a :: b :: rest ->
            let result = if b <= a then 1.0 else 0.0 in
            execute_bytecode instructions (result :: rest) env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during LESS_EQUAL")
    | Bytecode.NOT_EQUAL -> (
        match stack with
        | a :: b :: rest ->
            let result = if b <> 0.0 != (a <> 0.0) then 1.0 else 0.0 in
            execute_bytecode instructions (result :: rest) env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during NOT_EQUAL")
    | Bytecode.JUMP_IF_FALSE label -> (
        match stack with
        | value :: rest ->
            if value = 0.0 then execute_bytecode instructions rest env label
            else execute_bytecode instructions rest env (pc + 1)
        | [] -> failwith "Runtime Error: Stack underflow during JUMP_IF_FALSE")
    | Bytecode.JUMP label -> execute_bytecode instructions stack env label
    | Bytecode.RETURN -> (
        match stack with
        | [] -> failwith "Runtime Error: Stack is empty during RETURN"
        | hd :: _ -> hd)
    | Bytecode.PRINT -> (
        match stack with
        | value :: rest ->
            let int_value = int_of_float value in
            if Hashtbl.mem string_table int_value then
              let str = Hashtbl.find string_table int_value in
              let processed_str = replace_newline str in
              Printf.printf "%s" processed_str
            else if floor value = value then
              Printf.printf "%d" (int_of_float value)
            else Printf.printf "%f" value;
            execute_bytecode instructions rest env (pc + 1)
        | [] -> failwith "Runtime Error: Stack underflow during PRINT")
    | Bytecode.CONCAT -> (
        match stack with
        | a :: b :: rest ->
            let int_value1 = int_of_float a in
            let int_value2 = int_of_float b in
            let str_a =
              if Hashtbl.mem string_table int_value1 then
                Hashtbl.find string_table int_value1
              else
                failwith
                  "Runtime Error: First operand for CONCAT is not a string"
            in
            let str_b =
              if Hashtbl.mem string_table int_value2 then
                Hashtbl.find string_table int_value2
              else
                failwith
                  "Runtime Error: Second operand for CONCAT is not a string"
            in
            let concatenated_str = str_b ^ str_a in
            let new_id = add_string concatenated_str in
            execute_bytecode instructions
              (float_of_int new_id :: rest)
              env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during CONCAT")
    | Bytecode.LEN -> (
        match stack with
        | value :: rest ->
            let int_value = int_of_float value in
            if Hashtbl.mem string_table int_value then
              let str = Hashtbl.find string_table int_value in
              let length = float_of_int (String.length str) in
              execute_bytecode instructions (length :: rest) env (pc + 1)
            else failwith "Runtime Error: Stack value for LEN is not a string"
        | [] -> failwith "Runtime Error: Stack underflow during LEN")
    | Bytecode.TOSTRING -> (
        match stack with
        | value :: rest ->
            let str_value =
              if Hashtbl.mem string_table (int_of_float value) then
                Hashtbl.find string_table (int_of_float value)
              else if floor value = value then
                string_of_int (int_of_float value)
              else string_of_float value
            in
            let new_id = add_string str_value in
            execute_bytecode instructions
              (float_of_int new_id :: rest)
              env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during TOSTRING")
    | Bytecode.TOINT -> (
        match stack with
        | value :: rest ->
            let int_value =
              if Hashtbl.mem string_table (int_of_float value) then
                let str = Hashtbl.find string_table (int_of_float value) in
                try int_of_string str
                with Failure _ ->
                  failwith "Runtime Error: Invalid integer string"
              else
                try int_of_float value
                with Failure _ ->
                  failwith
                    "Runtime Error: Stack value for TOINT is not a valid number"
            in
            execute_bytecode instructions
              (float_of_int int_value :: rest)
              env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during TOINT")
    | Bytecode.TOFLOAT -> (
        match stack with
        | value :: rest ->
            let float_value =
              if Hashtbl.mem string_table (int_of_float value) then
                let str = Hashtbl.find string_table (int_of_float value) in
                try float_of_string str
                with Failure _ ->
                  failwith "Runtime Error: Invalid float string"
              else if snd (modf value) = 0.0 then
                float_of_int (int_of_float value)
              else value
            in
            execute_bytecode instructions (float_value :: rest) env (pc + 1)
        | _ -> failwith "Runtime Error: Stack underflow during TOFLOAT")
    | Bytecode.HALT -> (
        match stack with
        | [] -> failwith "Runtime Error: Stack is empty during HALT"
        | hd :: _ -> hd)

let run instructions =
  try execute_bytecode (Array.of_list instructions) [] [] 0
  with Failure msg -> failwith msg
