open Ast
open Typechecker
open Bytecode
open Interpreter

let eval_input input =
  let lexbuf = Lexing.from_string input in
  try
    let ast = Parser.program Lexer.token lexbuf in
    Printf.printf "Parsed AST:\n%s\n" (Stmt.show ast);

    let initial_env = TypeChecker.empty_env in

    let _ =
      TypeChecker.check_block initial_env [ ast ] ~expected_return_type:None
    in

    let bytecode = compile_stmt ast in
    List.iter
      (fun op ->
        Bytecode.pp_opcode Format.str_formatter op;
        let opcode_str = Format.flush_str_formatter () in
        Printf.printf "Generated opcode: %s\n" opcode_str)
      bytecode;
    let result = run bytecode in
    Printf.printf "Result: %f\n" result;

  with
  | e ->
      Printf.printf "An unexpected error occurred: %s\n" (Printexc.to_string e)

let get_version () =
    "0.0.1"

let rec repl () =
  let version = get_version () in
  let platform =
    match Sys.os_type with
    | "Unix" -> "Unix"
    | "Win32" -> "Windows"
    | _ -> "Unknown"
  in
  Printf.printf "Calyxium %s on %s\n" version platform;
  Printf.printf ">> ";
  let input = read_line () in
  if input <> "exit" then (
    eval_input input;
    repl ()
  ) else
    Printf.printf "Exiting REPL.\n"
