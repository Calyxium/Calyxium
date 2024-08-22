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

    let token_and_update_column t = 
      update_column ();
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
    | "+"                   { token_and_update_column Plus }
    | "-"                   { token_and_update_column Minus }
    | "*"                   { token_and_update_column Star }
    | "/"                   { token_and_update_column Slash }

    (* Groupings *)
    | "("                   { token_and_update_column LParen }
    | ")"                   { token_and_update_column RParen }
    | "["                   { token_and_update_column LBracket }
    | "]"                   { token_and_update_column RBracket }
    | "{"                   { token_and_update_column LBrace }
    | "}"                   { token_and_update_column RBrace }

    (* Symbols *)
    | "."                   { token_and_update_column Dot }
    | "?"                   { token_and_update_column Question }
    | ":"                   { token_and_update_column Colon }
    | ";"                   { token_and_update_column Semi }
    | ","                   { token_and_update_column Comma }
    | "!"                   { token_and_update_column Not }
    | "|"                   { token_and_update_column Pipe }
    | "&"                   { token_and_update_column Amspersand }
    | ">"                   { token_and_update_column Greater }
    | "<"                   { token_and_update_column Less }
    | "||"                  { column := !column + 1; LogicalOr }
    | "&&"                  { column := !column + 1; LogicalAnd }
    | "=="                  { column := !column + 1; Eq }
    | "!="                  { column := !column + 1; Neq }
    | ">="                  { column := !column + 1; Geq }
    | "<="                  { column := !column + 1; Leq }

    (* Assign *)
    | "="                   { token_and_update_column Assign }
    | "+="                  { column := !column + 1; PlusAssign }
    | "-="                  { column := !column + 1; MinusAssign }
    | "*="                  { column := !column + 1; StarAssign }
    | "/="                  { column := !column + 1; SlashAssign }

    (* Keywords *)
    | "function"            { column := !column + 7; Function }
    | "if"                  { column := !column + 1; If }
    | "else"                { column := !column + 3; Else }
    | "let"                 { column := !column + 2; Var }
    | "const"               { column := !column + 4; Const }
    | "switch"              { column := !column + 6; Switch }
    | "case"                { column := !column + 3; Case }
    | "break"               { column := !column + 4; Break }
    | "default"             { column := !column + 7; Default }
    | "return"              { column := !column + 6; Return}
    | "for"                 { column := !column + 2; For }
    | "try"                 { column := !column + 2; Try }
    | "catch"               { column := !column + 5; Catch }
    | "import"              { column := !column + 6; Import }
    | "export"              { column := !column + 6; Export }
    | "this"                { column := !column + 3; This }
    | "new"                 { column := !column + 2; New }
    | "null"                { column := !column + 3; Null }

    (*Types *)
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
    | "true"                { column := !column + 4; Bool true }
    | "false"               { column := !column + 5; Bool false }
    | eof                   { EOF }

and read_comment = parse
    | '\n'                 { incr line; column := 0; token lexbuf }
    | _                    { read_comment lexbuf }
    | eof                  { EOF }  