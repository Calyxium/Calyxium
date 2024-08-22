open Ast.Expr

let () =
  if Array.length Sys.argv <> 2 then
    Printf.printf "Usage: %s <filename>\n" Sys.argv.(0)
  else
    let filename = Sys.argv.(1) in
    let file_channel = open_in filename in
    let lexbuf = Lexing.from_channel file_channel in
    try
      let ast_list = Parser.program Lexer.token lexbuf in
      List.iter
        (fun ast -> Printf.printf "Parsed AST: %s\n" (to_string ast))
        ast_list;
      close_in file_channel
    with Parser.Error ->
      Printf.fprintf stderr "Parser error at token: %s\n" (Lexing.lexeme lexbuf);
      close_in file_channel;
      exit (-1)
