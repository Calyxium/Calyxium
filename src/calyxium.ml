open Ast.Stmt

let () =
  if Array.length Sys.argv <> 2 then
    Printf.printf "Usage: %s <filename>\n" Sys.argv.(0)
  else
    let filename = Sys.argv.(1) in
    let file_channel = open_in filename in
    let lexbuf = Lexing.from_channel file_channel in
    try
      let ast = Parser.program Lexer.token lexbuf in
      Printf.printf "%s\n" (show ast);
      close_in file_channel
    with
    | Parser.Error ->
        Printf.fprintf stderr "Parser error at line %d, column %d: %s\n"
          (Lexer.get_line ()) (Lexer.get_column ()) (Lexing.lexeme lexbuf);
        close_in file_channel;
        exit (-1)
    | e ->
        Printf.fprintf stderr "An unexpected error occurred: %s\n"
          (Printexc.to_string e);
        close_in file_channel;
        exit (-1)
