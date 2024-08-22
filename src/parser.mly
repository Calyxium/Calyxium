%{
    open Ast
%}

(* Prec *)
%left Plus Minus
%left Star Slash Mod
%left Pow

(* Operators *)
%token Plus Minus Star Slash Mod Pow
(* Groupings *)
%token LParen RParen LBracket RBracket LBrace RBrace
(* Symbols *)
%token Dot Question Colon Semi Comma Not Pipe Amspersand Greater Less
(* Logical *)
%token LogicalOr LogicalAnd Eq Neq Geq Leq
(* Assignment *)
%token Assign PlusAssign MinusAssign StarAssign SlashAssign
(* Keywords *)
%token Function If Else Var Const Switch Case Break Default For True False Try Catch Import Export This New Null Return Class
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
    | stmt_list EOF { Stmt.BlockStmt { body = $1 } }

stmt_list:
    | stmt Semi stmt_list { $1 :: $3 }
    | stmt Semi { [$1] }
    | stmt { [$1] }

stmt:
    | VarDeclStmt { $1 }
    | FunctionDeclStmt { $1 }
    | ReturnStmt { $1 }
    | IfStmt { $1 }
    | expr { Stmt.ExprStmt $1 }

IfStmt:
    | If LParen expr RParen LBrace stmt_list RBrace Else LBrace stmt_list RBrace {
        Stmt.IfStmt { condition = $3; then_branch = Stmt.BlockStmt { body = $6 }; else_branch = Some (Stmt.BlockStmt { body = $10 }); } }
    | If LParen expr RParen LBrace stmt_list RBrace Else LBrace stmt_list RBrace {
        Stmt.IfStmt { condition = $3; then_branch = Stmt.BlockStmt { body = $6 }; else_branch = Some (Stmt.BlockStmt { body = $10 }); } }
    | If LParen expr RParen LBrace stmt_list RBrace {
        Stmt.IfStmt { condition = $3; then_branch = Stmt.BlockStmt { body = $6 }; else_branch = None; } }

FunctionDeclStmt:
    | Function Ident LParen parameter_list RParen Colon type_expr LBrace stmt_list RBrace {
        Stmt.FunctionDeclStmt { name = $2; parameters = $4; return_type = Some $7; body = $9; } }
    | Function Ident LParen parameter_list RParen LBrace stmt_list RBrace {
        Stmt.FunctionDeclStmt { name = $2; parameters = $4; return_type = None; body = $7; } }

parameter_list:
    | parameter Comma parameter_list { $1 :: $3 }
    | parameter { [$1] }
    | { [] }

parameter:
    | Ident Colon type_expr { { Stmt.name = $1; param_type = $3 } }

ReturnStmt:
    | Return expr { Stmt.ReturnStmt $2 }
    | Return { Stmt.ReturnStmt (Expr.VarExpr "") }

VarDeclStmt:
    | Var Ident Colon type_expr Assign expr {
        Stmt.VarDeclarationStmt { identifier = $2; constant = false; assigned_value = Some $6; explicit_type = $4; } }
    | Const Ident Colon type_expr Assign expr {
        Stmt.VarDeclarationStmt { identifier = $2; constant = true; assigned_value = Some $6; explicit_type = $4; } }
    | Var Ident Colon type_expr {
        Stmt.VarDeclarationStmt { identifier = $2; constant = false; assigned_value = None; explicit_type = $4; } }

type_expr:
    | IntType { Type.SymbolType { value = "int" } }
    | FloatType { Type.SymbolType { value = "float" } }
    | StringType { Type.SymbolType { value = "string" } }
    | ByteType { Type.SymbolType { value = "byte" } }
    | BoolType { Type.SymbolType { value = "bool" } }

expr:
    | expr Plus expr { Expr.BinaryExpr { left = $1; operator = Plus; right = $3 } }
    | expr Minus expr { Expr.BinaryExpr { left = $1; operator = Minus; right = $3 } }
    | expr Star expr { Expr.BinaryExpr { left = $1; operator = Star; right = $3 } }
    | expr Slash expr { Expr.BinaryExpr { left = $1; operator = Slash; right = $3 } }
    | expr Mod expr { Expr.BinaryExpr { left = $1; operator = Mod; right = $3 } }
    | expr Pow expr { Expr.BinaryExpr { left = $1; operator = Pow; right = $3 } }
    | expr Greater expr { Expr.BinaryExpr { left = $1; operator = Greater; right = $3 } }
    | expr Less expr { Expr.BinaryExpr { left = $1; operator = Less; right = $3 } }
    | expr LogicalOr expr { Expr.BinaryExpr { left = $1; operator = LogicalOr; right = $3 } }
    | expr LogicalAnd expr { Expr.BinaryExpr { left = $1; operator = LogicalAnd; right = $3 } }
    | expr Eq expr { Expr.BinaryExpr { left = $1; operator = Eq; right = $3 } }
    | expr Neq expr { Expr.BinaryExpr { left = $1; operator = Neq; right = $3 } }
    | expr Geq expr { Expr.BinaryExpr { left = $1; operator = Geq; right = $3 } }
    | expr Leq expr { Expr.BinaryExpr { left = $1; operator = Leq; right = $3 } }
    | Int { Expr.IntExpr { value = $1 } }
    | Float { Expr.FloatExpr { value = $1 } }
    | String { Expr.StringExpr { value = $1 } }
    | Byte { Expr.ByteExpr { value = $1 } }
    | Ident { Expr.VarExpr $1 }
