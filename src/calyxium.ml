open Token

let () =
  if Array.length Sys.argv <> 2 then
    Printf.printf "Usage: %s <filename>\n" Sys.argv.(0)
  else
    let filename = Sys.argv.(1) in
    let file_channel = open_in filename in
    let lexbuf = Lexing.from_channel file_channel in
    let rec loop () =
      match Lexer.token lexbuf with
      | Token.EOF -> close_in file_channel
      | token ->
        Printf.printf "Token: %s\n" (Token.string_of_token token);
        loop ()
    in
    loop ()