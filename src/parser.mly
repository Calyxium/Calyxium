%{
    open Ast
%}

%left Plus Minus
%left Star Slash

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
    | Ident                 { Expr.Var $1 }
    | expr Plus expr        { Expr.BinOp (Plus, $1, $3) }
    | expr Minus expr       { Expr.BinOp (Minus, $1, $3) }
    | expr Star expr        { Expr.BinOp (Star, $1, $3) }
    | expr Slash expr       { Expr.BinOp (Slash, $1, $3) }
    | expr Less expr        { Expr.BinOp (Less, $1, $3) }
    | expr Greater expr     { Expr.BinOp (Greater, $1, $3) }
    | expr Eq expr          { Expr.BinOp (Eq, $1, $3) }
    | expr Neq expr         { Expr.BinOp (Neq, $1, $3) }
    | expr Leq expr         { Expr.BinOp (Leq, $1, $3) }
    | expr Geq expr         { Expr.BinOp (Geq, $1, $3) }
    | VarDecl               { $1 }

VarDecl:
    | Var Ident Colon type_expr Assign expr { Expr.VarDecl ($2, $4, Some $6) }
    | Var Ident Colon type_expr             { Expr.VarDecl ($2, $4, None) }

type_expr:
    | IntType                      { IntType }
    | FloatType                    { FloatType }
    | StringType                   { StringType }
    | ByteType                     { ByteType }
    | BoolType                     { BoolType }