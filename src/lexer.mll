{
    open Token
}

let Identifier = ['a'-'z' 'A'-'Z' '_']*
let Digits = ['0'-'9']+
let Floats = Digits '.' Digits+

rule token = parse
    | [' ' '\t' '\n']      { token lexbuf }
    
    (* Operators *)
    | '+'                  { Token.Plus }
    | '-'                  { Token.Minus }
    | '*'                  { Token.Star }
    | '/'                  { Token.Slash }

    (* Symbols *)
    | '('                  { Token.LParen }
    | ')'                  { Token.RParen }
    | '['                  { Token.LBracket }
    | ']'                  { Token.RBracket }
    | '{'                  { Token.LBrace }
    | '}'                  { Token.RBrace }
    | '.'                  { Token.Dot }
    | '?'                  { Token.Question }
    | ':'                  { Token.Colon }
    | ';'                  { Token.Semi }
    | ','                  { Token.Comma }
    | '!'                  { Token.Not }
    | '|'                  { Token.Pipe }
    | '&'                  { Token.Amspersand }
    | '>'                  { Token.Greater }
    | '<'                  { Token.Less }

    (* Logical *)
    | "||"                 { Token.LogicalOr }
    | "&&"                 { Token.LogicalAnd }
    | "=="                 { Token.Eq }
    | "!="                 { Token.Neq }
    | ">="                 { Token.Geq }
    | "<="                 { Token.Leq }

    (* Assignment *)
    | '='                  { Token.Assign }
    | "+="                 { Token.PlusAssign }
    | "-="                 { Token.MinusAssign }
    | "*="                 { Token.StarAssign }
    | "/="                 { Token.SlashAssign }

    (* Keywords *)
    | "function"           { Token.Function }
    | "if"                 { Token.If }
    | "else"               { Token.Else }
    | "let"                { Token.Var }
    | "const"              { Token.Const }
    | "switch"             { Token.Switch }
    | "case"               { Token.Case }
    | "break"              { Token.Break }
    | "default"            { Token.Default }
    | "for"                { Token.For }
    | "try"                { Token.Try }
    | "catch"              { Token.Catch }
    | "import"             { Token.Import }
    | "export"             { Token.Export }
    | "this"               { Token.This }
    | "null"               { Token.Null }

    (* Types *)
    | "int"                { Token.IntType }
    | "float"              { Token.FloatType }
    | "string"             { Token.StringType }
    | "byte"               { Token.ByteType }
    | "bool"               { Token.BoolType }

    (* Literals *)
    | Identifier           { Token.Ident (Lexing.lexeme lexbuf) }
    | Floats               { Token.Float (float_of_string (Lexing.lexeme lexbuf)) }
    | Digits               { Token.Int (int_of_string (Lexing.lexeme lexbuf)) }
    | '\'' [^'\''] '\''    { Token.Byte (Lexing.lexeme lexbuf).[1] }
    | '"' [^'"']* '"'      { Token.String (String.sub (Lexing.lexeme lexbuf) 1 (String.length (Lexing.lexeme lexbuf) - 2)) }
    | "true"               { Token.Bool true }
    | "false"              { Token.Bool false }
    | eof                  { Token.EOF }