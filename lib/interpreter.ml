let rec execute_bytecode instructions stack pc =
  if pc >= Array.length instructions then List.hd stack
  else
    match instructions.(pc) with
    | Bytecode.LOAD_INT value ->
        execute_bytecode instructions (float_of_int value :: stack) (pc + 1)
    | Bytecode.LOAD_FLOAT value ->
        execute_bytecode instructions (value :: stack) (pc + 1)
    | Bytecode.FADD ->
        let a = List.hd stack in
        let b = List.hd (List.tl stack) in
        execute_bytecode instructions
          ((b +. a) :: List.tl (List.tl stack))
          (pc + 1)
    | Bytecode.FSUB ->
        let a = List.hd stack in
        let b = List.hd (List.tl stack) in
        execute_bytecode instructions
          ((b -. a) :: List.tl (List.tl stack))
          (pc + 1)
    | Bytecode.FMUL ->
        let a = List.hd stack in
        let b = List.hd (List.tl stack) in
        execute_bytecode instructions
          ((b *. a) :: List.tl (List.tl stack))
          (pc + 1)
    | Bytecode.FDIV ->
        let a = List.hd stack in
        let b = List.hd (List.tl stack) in
        execute_bytecode instructions
          ((b /. a) :: List.tl (List.tl stack))
          (pc + 1)
    | Bytecode.MOD ->
        let a = List.hd stack in
        let b = List.hd (List.tl stack) in
        execute_bytecode instructions
          (mod_float b a :: List.tl (List.tl stack))
          (pc + 1)
    | Bytecode.POW ->
        let a = List.hd stack in
        let b = List.hd (List.tl stack) in
        execute_bytecode instructions
          ((b ** a) :: List.tl (List.tl stack))
          (pc + 1)
    | Bytecode.POP -> execute_bytecode instructions (List.tl stack) (pc + 1)
    | Bytecode.RETURN -> List.hd stack
    | Bytecode.HALT -> List.hd stack

let run instructions = execute_bytecode (Array.of_list instructions) [] 0
