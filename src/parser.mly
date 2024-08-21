%{
    open Ast
%}

(* Operators *)
%token Plus Minus Star Slash
(* Groupings *)
%token LParen RParen LBracket RBracket LBrace RBrace
(* Symbols *)
%token Dot Question Colon Semi Comma Not Pipe Amspersand Greater Less
(* Logical *)
%token LogicalOr LogicalAnd Eq Neq Geq Leq
(* Assignment *)
%token Assign PlusAssign MinusAssign StarAssign SlashAssign
(* Keywords *)
%token Function If Else Var Const Switch Case Break Default For True False Try Catch Import Export This New Null Return
(* Types *)
%token IntType FloatType StringType ByteType BoolType
(* Literals *)
%token <string> Ident
%token <int> Int
%token <float> Float
%token <string> String
%token <char> Byte
%token <bool> Bool
(* EOF *)
%token EOF

%start program
%type <Expr.t list> program

%%

program:
    | expr_list EOF         { $1 }

expr_list:
    | expr Semi expr_list   { $1 :: $3 }
    | expr Semi             { [$1] }
    | expr                  { [$1] }

expr:
    | Int                   { Expr.Int $1 }
    | Float                 { Expr.Float $1 }
    | expr Plus expr        { Expr.BinOp (Plus, $1, $3) }
    | expr Minus expr       { Expr.BinOp (Minus, $1, $3) }
    | expr Star expr        { Expr.BinOp (Star, $1, $3) }
    | expr Slash expr       { Expr.BinOp (Slash, $1, $3) }