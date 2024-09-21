let stack : float Stack.t = Stack.create ()
let string_table = Hashtbl.create 10
let gc_threshold = ref 256

let log_memory_usage label =
  let stats = Gc.stat () in
  Printf.printf
    "[%s] Memory usage: minor_words = %.2f, major_words = %.2f, heap_size = %d \
     KB, GCs = %d minor, %d major\n"
    label stats.Gc.minor_words stats.Gc.major_words
    (stats.Gc.heap_words * 8 / 1024)
    stats.Gc.minor_collections stats.Gc.major_collections

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
        process_chars (i + 2))
      else (
        Buffer.add_char buffer str.[i];
        process_chars (i + 1))
  in
  process_chars 0;
  Buffer.contents buffer

let trigger_gc instruction_count =
  if instruction_count > !gc_threshold then (
    Gc.full_major ();
    gc_threshold := !gc_threshold + 256)

let rec execute_bytecode instructions env pc =
  if pc >= Array.length instructions then
    match Stack.top_opt stack with None -> 0.0 | Some hd -> hd
  else
    let instruction_count = pc + 1 in
    trigger_gc instruction_count;
    if instruction_count mod 256 = 0 then log_memory_usage "Instruction Count";
    match instructions.(pc) with
    | Bytecode.LOAD_INT value ->
        Stack.push (float_of_int value) stack;
        execute_bytecode instructions env (pc + 1)
    | Bytecode.LOAD_FLOAT value ->
        Stack.push value stack;
        execute_bytecode instructions env (pc + 1)
    | Bytecode.LOAD_STRING value ->
        let id = Hashtbl.hash value in
        Hashtbl.add string_table id value;
        Stack.push (float_of_int id) stack;
        execute_bytecode instructions env (pc + 1)
    | Bytecode.LOAD_BYTE value ->
        let id = Hashtbl.hash (String.make 1 value) in
        Hashtbl.add string_table id (String.make 1 value);
        Stack.push (float_of_int id) stack;
        execute_bytecode instructions env (pc + 1)
    | Bytecode.LOAD_BOOL value ->
        Stack.push (if value then 1.0 else 0.0) stack;
        execute_bytecode instructions env (pc + 1)
    | Bytecode.LOAD_VAR name -> (
        match List.assoc_opt name env with
        | Some (value, _) ->
            Stack.push value stack;
            execute_bytecode instructions env (pc + 1)
        | None -> failwith ("Runtime Error: Variable " ^ name ^ " not found"))
    | Bytecode.STORE_VAR name ->
        if Stack.is_empty stack then
          failwith "Runtime Error: Stack is empty when trying to store variable"
        else
          let value = Stack.pop stack in
          let env = (name, (value, true)) :: List.remove_assoc name env in
          execute_bytecode instructions env (pc + 1)
    | Bytecode.FADD ->
        if Stack.length stack < 2 then
          failwith "Runtime Error: Stack underflow during FADD"
        else
          let a = Stack.pop stack in
          let b = Stack.pop stack in
          Stack.push (b +. a) stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.FSUB ->
        if Stack.length stack < 2 then
          failwith "Runtime Error: Stack underflow during FSUB"
        else
          let a = Stack.pop stack in
          let b = Stack.pop stack in
          Stack.push (b -. a) stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.FMUL ->
        if Stack.length stack < 2 then
          failwith "Runtime Error: Stack underflow during FMUL"
        else
          let a = Stack.pop stack in
          let b = Stack.pop stack in
          Stack.push (b *. a) stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.FDIV ->
        if Stack.length stack < 2 then
          failwith "Runtime Error: Stack underflow during FDIV"
        else
          let a = Stack.pop stack in
          let b = Stack.pop stack in
          if a = 0.0 then failwith "Runtime Error: Division by zero"
          else Stack.push (b /. a) stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.MOD ->
        if Stack.length stack < 2 then
          failwith "Runtime Error: Stack underflow during MOD"
        else
          let a = Stack.pop stack in
          let b = Stack.pop stack in
          Stack.push (mod_float b a) stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.POW ->
        if Stack.length stack < 2 then
          failwith "Runtime Error: Stack underflow during POW"
        else
          let a = Stack.pop stack in
          let b = Stack.pop stack in
          Stack.push (b ** a) stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.RETURN ->
        let return_value = Stack.pop stack in
        Stack.push return_value stack;
        execute_bytecode instructions env (pc + 2)
    | Bytecode.CALL function_name -> (
        try
          let function_body =
            Hashtbl.find Bytecode.function_table function_name
          in
          let return_address = float_of_int (pc + 1) in
          Stack.push return_address stack;
          execute_bytecode (Array.of_list function_body) env 0
        with Not_found ->
          failwith ("Runtime Error: Function '" ^ function_name ^ "' not found")
        )
    | Bytecode.PRINT ->
        if Stack.is_empty stack then
          failwith "Runtime Error: Stack underflow during PRINT"
        else
          let value = Stack.pop stack in
          let int_value = int_of_float value in
          if Hashtbl.mem string_table int_value then
            let str = Hashtbl.find string_table int_value in
            let proc_str = replace_newline str in
            Printf.printf "%s" proc_str
          else if floor value = value then
            Printf.printf "%d" (int_of_float value)
          else Printf.printf "%f" value;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.PRINTLN ->
        if Stack.is_empty stack then
          failwith "Runtime Error: Stack underflow during PRINTLN"
        else
          let value = Stack.pop stack in
          let int_value = int_of_float value in
          if Hashtbl.mem string_table int_value then
            let str = Hashtbl.find string_table int_value in
            Printf.printf "%s\n" str
          else if floor value = value then
            Printf.printf "%d\n" (int_of_float value)
          else Printf.printf "%f\n" value;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.LEN ->
        if Stack.is_empty stack then
          failwith "Runtime Error: Stack underflow during LEN"
        else
          let value = Stack.pop stack in
          let int_value = int_of_float value in
          if Hashtbl.mem string_table int_value then (
            let str = Hashtbl.find string_table int_value in
            let length = float_of_int (String.length str) in
            Stack.push length stack;
            execute_bytecode instructions env (pc + 1))
          else failwith "Runtime Error: LEN expects a string"
    | Bytecode.TOSTRING ->
        if Stack.is_empty stack then
          failwith "Runtime Error: Stack underflow during TOSTRING"
        else
          let value = Stack.pop stack in
          let str_value =
            if Hashtbl.mem string_table (int_of_float value) then
              Hashtbl.find string_table (int_of_float value)
            else if floor value = value then string_of_int (int_of_float value)
            else string_of_float value
          in
          let new_id = add_string str_value in
          Stack.push (float_of_int new_id) stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.TOINT ->
        if Stack.is_empty stack then
          failwith "Runtime Error: Stack underflow during TOINT"
        else
          let value = Stack.pop stack in
          let int_value =
            if Hashtbl.mem string_table (int_of_float value) then
              let str = Hashtbl.find string_table (int_of_float value) in
              try int_of_string str
              with Failure _ ->
                failwith "Runtime Error: Invalid integer string"
            else int_of_float value
          in
          Stack.push (float_of_int int_value) stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.TOFLOAT ->
        if Stack.is_empty stack then
          failwith "Runtime Error: Stack underflow during TOFLOAT"
        else
          let value = Stack.pop stack in
          let float_value =
            if Hashtbl.mem string_table (int_of_float value) then
              let str = Hashtbl.find string_table (int_of_float value) in
              try float_of_string str
              with Failure _ -> failwith "Runtime Error: Invalid float string"
            else if snd (modf value) = 0.0 then
              float_of_int (int_of_float value)
            else value
          in
          Stack.push float_value stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.CONCAT ->
        if Stack.length stack < 2 then
          failwith "Runtime Error: Stack underflow during CONCAT"
        else
          let a = Stack.pop stack in
          let b = Stack.pop stack in
          let str_a =
            if Hashtbl.mem string_table (int_of_float a) then
              Hashtbl.find string_table (int_of_float a)
            else
              failwith "Runtime Error: First operand for CONCAT is not a string"
          in
          let str_b =
            if Hashtbl.mem string_table (int_of_float b) then
              Hashtbl.find string_table (int_of_float b)
            else
              failwith
                "Runtime Error: Second operand for CONCAT is not a string"
          in
          let concatenated_str = str_b ^ str_a in
          let new_id = add_string concatenated_str in
          Stack.push (float_of_int new_id) stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.PUSH_ARGS -> execute_bytecode instructions env (pc + 1)
    | Bytecode.FUNC _ ->
        let rec skip_function pc =
          match instructions.(pc) with
          | Bytecode.RETURN -> pc + 1
          | _ -> skip_function (pc + 1)
        in
        execute_bytecode instructions env (skip_function (pc + 1))
    | Bytecode.JUMP_IF_FALSE label ->
        let condition = Stack.pop stack in
        if condition = 0.0 then execute_bytecode instructions env (pc + label)
        else execute_bytecode instructions env (pc + 1)
    | Bytecode.JUMP label -> execute_bytecode instructions env (pc + label)
    | Bytecode.LESS ->
        if Stack.length stack < 2 then
          failwith "Runtime Error: Stack underflow during LESS"
        else
          let a = Stack.pop stack in
          let b = Stack.pop stack in
          if b < a then Stack.push 1.0 stack else Stack.push 0.0 stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.GREATER ->
        if Stack.length stack < 2 then
          failwith "Runtime Error: Stack under during GREATER"
        else
          let a = Stack.pop stack in
          let b = Stack.pop stack in
          if b > a then Stack.push 1.0 stack else Stack.push 0.0 stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.GREATER_EQUAL ->
        if Stack.length stack < 2 then
          failwith "Runtime Error: Stack under during GREATER"
        else
          let a = Stack.pop stack in
          let b = Stack.pop stack in
          if b >= a then Stack.push 1.0 stack else Stack.push 0.0 stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.LESS_EQUAL ->
        if Stack.length stack < 2 then
          failwith "Runtime Error: Stack under during GREATER"
        else
          let a = Stack.pop stack in
          let b = Stack.pop stack in
          if b <= a then Stack.push 1.0 stack else Stack.push 0.0 stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.NOT_EQUAL ->
        if Stack.length stack < 2 then
          failwith "Runtime Error: Stack under during GREATER"
        else
          let a = Stack.pop stack in
          let b = Stack.pop stack in
          if b <> a then Stack.push 1.0 stack else Stack.push 0.0 stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.EQUAL ->
        if Stack.length stack < 2 then
          failwith "Runtime Error: Stack under during GREATER"
        else
          let a = Stack.pop stack in
          let b = Stack.pop stack in
          if b = a then Stack.push 1.0 stack else Stack.push 0.0 stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.AND ->
        if Stack.length stack < 2 then
          failwith "Runtime Error: Stack underflow during AND"
        else
          let a = Stack.pop stack in
          let b = Stack.pop stack in
          if b <> 0.0 && a <> 0.0 then Stack.push 1.0 stack
          else Stack.push 0.0 stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.OR ->
        if Stack.length stack < 2 then
          failwith "Runtime Error: Stack underflow during OR"
        else
          let a = Stack.pop stack in
          let b = Stack.pop stack in
          if b <> 0.0 || a <> 0.0 then Stack.push 1.0 stack
          else Stack.push 0.0 stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.INC ->
        if Stack.is_empty stack then
          failwith "Runtime Error: Stack underflow during INC"
        else
          let value = Stack.pop stack in
          Stack.push (value +. 1.0) stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.DEC ->
        if Stack.is_empty stack then
          failwith "Runtime Error: Stack underflow during DEC"
        else
          let value = Stack.pop stack in
          Stack.push (value -. 1.0) stack;
          execute_bytecode instructions env (pc + 1)
    | Bytecode.LOAD_ARRAY length ->
        let array = Stack.create () in
        for _ = 1 to length do
          let element = Stack.pop stack in
          Stack.push element array
        done;
        Stack.push (Obj.magic array : float) stack;
        execute_bytecode instructions env (pc + 1)
    | Bytecode.LOAD_INDEX ->
        let index = int_of_float (Stack.pop stack) in
        let array_stack = (Obj.magic (Stack.pop stack) : float Stack.t) in
        let array_list =
          Stack.fold (fun acc x -> x :: acc) [] array_stack |> List.rev
        in
        let element = List.nth array_list index in
        Stack.push element stack;
        execute_bytecode instructions env (pc + 1)
    | Bytecode.SWITCH ->
        let switch_value = Stack.pop stack in
        let rec execute_cases pc =
          match instructions.(pc) with
          | Bytecode.CASE value ->
              if switch_value = value then
                execute_bytecode instructions env (pc + 1)
              else execute_cases (pc + 1)
          | Bytecode.DEFAULT -> execute_bytecode instructions env (pc + 1)
          | _ -> failwith "Runtime Error: Unexpected bytecode in SWITCH"
        in
        execute_cases (pc + 1)
    | Bytecode.DUP ->
        if Stack.is_empty stack then
          failwith "Runtime Error: Stack underflow during DUP"
        else
          let top_value = Stack.top stack in
          Stack.push top_value stack;
          execute_bytecode instructions env (pc + 1)
    | _ -> failwith "Runtime Error: Unsupported opcode"

let run instructions =
  try execute_bytecode (Array.of_list instructions) [] 0
  with Failure msg -> failwith msg
