

val string_table : (int, string) Hashtbl.t
val add_string : string -> int
val replace_newline : string -> string

val execute_bytecode :
  Bytecode.opcode array ->
  float list ->
  (string * (float * bool)) list ->
  int ->
  float

val run : Bytecode.opcode list -> float
