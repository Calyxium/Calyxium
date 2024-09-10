{
    open Parser

    let line = ref 1
    let column = ref 0

    let get_line () = !line
    let get_column () = !column

    let update_column () =
      incr column

    let update_line () =
      incr line;
      column := 0

    let token_and_update_column t lexbuf =
      let token_length = Lexing.lexeme_end lexbuf - Lexing.lexeme_start lexbuf in
      column := !column + token_length;
      t
}

let Identifier = ['a'-'z' 'A'-'Z' '_']*
let Digits = ['0'-'9']+
let Floats = Digits '.' Digits+

rule token = parse
    | [' ' '\t']            { update_column (); token lexbuf }
    | '\n'                  { update_line (); token lexbuf }
    | "#"                   { read_comment lexbuf }

    (* Operators *)
    | "+"                   { token_and_update_column Plus lexbuf }
    | "-"                   { token_and_update_column Minus lexbuf }
    | "*"                   { token_and_update_column Star lexbuf }
    | "/"                   { token_and_update_column Slash lexbuf }

    (* Groupings *)
    | "("                   { token_and_update_column LParen lexbuf }
    | ")"                   { token_and_update_column RParen lexbuf }
    | "["                   { token_and_update_column LBracket lexbuf }
    | "]"                   { token_and_update_column RBracket lexbuf }
    | "{"                   { token_and_update_column LBrace lexbuf }
    | "}"                   { token_and_update_column RBrace lexbuf }

    (* Symbols *)
    | "."                   { token_and_update_column Dot lexbuf }
    | "?"                   { token_and_update_column Question lexbuf }
    | ":"                   { token_and_update_column Colon lexbuf }
    | ";"                   { token_and_update_column Semi lexbuf }
    | ","                   { token_and_update_column Comma lexbuf }
    | "!"                   { token_and_update_column Not lexbuf }
    | "|"                   { token_and_update_column Pipe lexbuf }
    | "&"                   { token_and_update_column Amspersand lexbuf }
    | ">"                   { token_and_update_column Greater lexbuf }
    | "<"                   { token_and_update_column Less lexbuf }
    | "^"                   { token_and_update_column Pow lexbuf }
    | "%"                   { token_and_update_column Mod lexbuf }
    | "||"                  { column := !column + 2; LogicalOr }
    | "&&"                  { column := !column + 2; LogicalAnd }
    | "=="                  { column := !column + 2; Eq }
    | "!="                  { column := !column + 2; Neq }
    | ">="                  { column := !column + 2; Geq }
    | "<="                  { column := !column + 2; Leq }
    | "--"                  { column := !column + 2; Dec }
    | "++"                  { column := !column + 2; Inc }

    (* Assign *)
    | "="                   { token_and_update_column Assign lexbuf }
    | "+="                  { column := !column + 2; PlusAssign }
    | "-="                  { column := !column + 2; MinusAssign }
    | "*="                  { column := !column + 2; StarAssign }
    | "/="                  { column := !column + 2; SlashAssign }

    (* Keywords *)
    | "fn"                  { column := !column + 2; Function }
    | "if"                  { column := !column + 2; If }
    | "else"                { column := !column + 4; Else }
    | "let"                 { column := !column + 3; Var }
    | "const"               { column := !column + 5; Const }
    | "switch"              { column := !column + 7; Switch }
    | "case"                { column := !column + 4; Case }
    | "break"               { column := !column + 5; Break }
    | "default"             { column := !column + 8; Default }
    | "return"              { column := !column + 7; Return}
    | "for"                 { column := !column + 3; For }
    | "import"              { column := !column + 7; Import }
    | "export"              { column := !column + 7; Export }
    | "class"               { column := !column + 6; Class }
    | "new"                 { column := !column + 3; New }
    | "true"                { column := !column + 4; True }
    | "false"               { column := !column + 5; False }
    | "null"                { column := !column + 4; Null }

    (* Types *)
    | "int"                 { column := !column + 3; IntType }
    | "float"               { column := !column + 5; FloatType }
    | "string"              { column := !column + 6; StringType }
    | "byte"                { column := !column + 4; ByteType }
    | "bool"                { column := !column + 4; BoolType }

    (* Literals *)
    | Identifier            { let lexeme = Lexing.lexeme lexbuf in column := !column + String.length lexeme; Ident lexeme }
    | Floats                { let lexeme = Lexing.lexeme lexbuf in column := !column + String.length lexeme; Float (float_of_string lexeme) }
    | Digits                { let lexeme = Lexing.lexeme lexbuf in column := !column + String.length lexeme; Int (int_of_string lexeme) }
    | '\'' [^'\''] '\''     { let lexeme = Lexing.lexeme lexbuf in column := !column + String.length lexeme; Byte (lexeme.[1]) }
    | '"' [^'"']* '"'       { let lexeme = Lexing.lexeme lexbuf in column := !column + String.length lexeme; String (String.sub lexeme 1 (String.length lexeme - 2)) }
    | eof                   { EOF }

and read_comment = parse
    | '\n'                 { incr line; column := 0; token lexbuf }
    | _                    { read_comment lexbuf }
    | eof                  { EOF }
