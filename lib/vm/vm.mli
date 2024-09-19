val stack : float Stack.t
val string_table : (int, string) Hashtbl.t
val gc_threshold : int ref
val add_string : string -> int
val replace_newline : string -> string
val trigger_gc : int -> unit

val execute_bytecode :
  Bytecode.opcode array -> (string * (float * bool)) list -> int -> float

val log_memory_usage : string -> unit
val run : Bytecode.opcode list -> float
