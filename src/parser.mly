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
%type <Stmt.t> program

%%

program:
    | stmt_list EOF         { Stmt.BlockStmt { body = $1 } }

stmt_list:
    | stmt Semi stmt_list   { $1 :: $3 }
    | stmt Semi             { [$1] }
    | stmt                  { [$1] }

stmt:
    | VarDeclStmt           { $1 }
    | expr                  { Stmt.ExprStmt $1 }

VarDeclStmt:
    | Var Ident Colon type_expr Assign expr {
        Stmt.VarDeclarationStmt {
          identifier = $2;
          constant = false;
          assigned_value = Some $6;
          explicit_type = $4;
        }
      }
    | Const Ident Colon type_expr Assign expr {
        Stmt.VarDeclarationStmt {
          identifier = $2;
          constant = true;
          assigned_value = Some $6;
          explicit_type = $4;
        }
      }
    | Var Ident Colon type_expr {
        Stmt.VarDeclarationStmt {
          identifier = $2;
          constant = false;
          assigned_value = None;
          explicit_type = $4;
        }
      }

type_expr:
    | IntType   { Type.SymbolType { value = "int" } }
    | FloatType { Type.SymbolType { value = "float" } }
    | StringType { Type.SymbolType { value = "string" } }
    | ByteType { Type.SymbolType { value = "byte" } }
    | BoolType { Type.SymbolType { value = "bool" } }

expr:
    | expr Plus expr  { Expr.BinaryExpr { left = $1; operator = Plus; right = $3 } }
    | expr Minus expr { Expr.BinaryExpr { left = $1; operator = Minus; right = $3 } }
    | expr Star expr  { Expr.BinaryExpr { left = $1; operator = Star; right = $3 } }
    | expr Slash expr { Expr.BinaryExpr { left = $1; operator = Slash; right = $3 } }
    | Int   { Expr.IntExpr { value = $1 } }
    | Float { Expr.FloatExpr { value = $1 } }
    | String { Expr.VarExpr $1 }
    | Byte { Expr.VarExpr (String.make 1 $1) }
    | Ident { Expr.VarExpr $1 }
