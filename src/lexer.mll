{
    open Parser
}

let Identifier = ['a'-'z' 'A'-'Z' '_']*
let Digits = ['0'-'9']+
let Floats = Digits '.' Digits+

rule token = parse
    | [' ' '\t' '\n']      { token lexbuf }
    | "#"                  { read_comment lexbuf }

    (* Operators *)
    | '+'                  { Plus }
    | '-'                  { Minus }
    | '*'                  { Star }
    | '/'                  { Slash }

    (* Symbols *)
    | '('                  { LParen }
    | ')'                  { RParen }
    | '['                  { LBracket }
    | ']'                  { RBracket }
    | '{'                  { LBrace }
    | '}'                  { RBrace }
    | '.'                  { Dot }
    | '?'                  { Question }
    | ':'                  { Colon }
    | ';'                  { Semi }
    | ','                  { Comma }
    | '!'                  { Not }
    | '|'                  { Pipe }
    | '&'                  { Amspersand }
    | '>'                  { Greater }
    | '<'                  { Less }

    (* Logical *)
    | "||"                 { LogicalOr }
    | "&&"                 { LogicalAnd }
    | "=="                 { Eq }
    | "!="                 { Neq }
    | ">="                 { Geq }
    | "<="                 { Leq }

    (* Assignment *)
    | '='                  { Assign }
    | "+="                 { PlusAssign }
    | "-="                 { MinusAssign }
    | "*="                 { StarAssign }
    | "/="                 { SlashAssign }

    (* Keywords *)
    | "function"           { Function }
    | "if"                 { If }
    | "else"               { Else }
    | "let"                { Var }
    | "const"              { Const }
    | "switch"             { Switch }
    | "case"               { Case }
    | "break"              { Break }
    | "default"            { Default }
    | "for"                { For }
    | "try"                { Try }
    | "catch"              { Catch }
    | "import"             { Import }
    | "export"             { Export }
    | "this"               { This }
    | "new"                { New }
    | "null"               { Null }

    (* Types *)
    | "int"                { IntType }
    | "float"              { FloatType }
    | "string"             { StringType }
    | "byte"               { ByteType }
    | "bool"               { BoolType }

    (* Literals *)
    | Identifier           { Ident (Lexing.lexeme lexbuf) }
    | Floats               { Float (float_of_string (Lexing.lexeme lexbuf)) }
    | Digits               { Int (int_of_string (Lexing.lexeme lexbuf)) }
    | '\'' [^'\''] '\''    { Byte (Lexing.lexeme lexbuf).[1] }
    | '"' [^'"']* '"'      { String (String.sub (Lexing.lexeme lexbuf) 1 (String.length (Lexing.lexeme lexbuf) - 2)) }
    | "true"               { Bool true }
    | "false"              { Bool false }
    | eof                  { EOF }

and read_comment = parse
    | '\n'                 { token lexbuf }
    | _                    { read_comment lexbuf }
    | eof                  { EOF }  