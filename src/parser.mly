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
%token Function If Else Var Const Switch Case Break Default For Import Export New Null Return Class
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
    | NewVarDeclStmt { $1 }
    | FunctionDeclStmt { $1 }
    | ReturnStmt { $1 }
    | IfStmt { $1 }
    | ForStmt { $1 }
    | ClassDeclStmt { $1 }
    | ImportStmt { $1 }
    | ExportStmt { $1 }
    | expr Assign expr { Stmt.ExprStmt (Expr.BinaryExpr { left = $1; operator = Assign; right = $3 }) }
    | expr { Stmt.ExprStmt $1 }

stmt_opt:
    | stmt { Some $1 }
    | { Some (Stmt.ExprStmt (Expr.NullExpr)) }

expr_opt:
    | expr { Some $1 }
    | { Some Expr.NullExpr }

parameter_list:
    | parameter Comma parameter_list { $1 :: $3 }
    | parameter { [$1] }
    | { [] }

parameter:
    | Ident Colon type_expr { { Stmt.name = $1; param_type = $3 } }

type_expr:
    | IntType { Type.SymbolType { value = "int" } }
    | FloatType { Type.SymbolType { value = "float" } }
    | StringType { Type.SymbolType { value = "string" } }
    | ByteType { Type.SymbolType { value = "byte" } }
    | BoolType { Type.SymbolType { value = "bool" } }
    | LBracket RBracket type_expr { Type.ArrayType { element_type = $3 } }

expr:
    | New Ident { Expr.NewExpr { class_name = $2; arguments = [] } }
    | expr Dot Ident LParen argument_list RParen { Expr.CallExpr { callee = Expr.PropertyAccessExpr { object_name = $1; property_name = $3 }; arguments = $5 } }
    | expr Dot Ident { Expr.PropertyAccessExpr { object_name = $1; property_name = $3 } }
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
    | expr PlusAssign expr { Expr.BinaryExpr { left = $1; operator = PlusAssign; right = $3 } }
    | expr MinusAssign expr { Expr.BinaryExpr { left = $1; operator = MinusAssign; right = $3 } }
    | expr StarAssign expr { Expr.BinaryExpr { left = $1; operator = StarAssign; right = $3 } }
    | expr SlashAssign expr { Expr.BinaryExpr { left = $1; operator = SlashAssign; right = $3 } }
    | Not expr { Expr.UnaryExpr { operator = Not; operand = $2 } }
    | Amspersand expr { Expr.UnaryExpr { operator = Amspersand; operand = $2 } }
    | Pipe expr { Expr.UnaryExpr { operator = Pipe; operand = $2 } }
    | Question expr { Expr.UnaryExpr { operator = Question; operand = $2 } }
    | Ident LParen argument_list RParen { Expr.CallExpr { callee = Expr.VarExpr $1; arguments = $3 } }
    | Null { Expr.NullExpr }
    | Minus Int { Expr.IntExpr { value = -$2 } }
    | Minus Float { Expr.FloatExpr { value = -. $2 } }
    | Int { Expr.IntExpr { value = $1 } }
    | Float { Expr.FloatExpr { value = $1 } }
    | String { Expr.StringExpr { value = $1 } }
    | Byte { Expr.ByteExpr { value = $1 } }
    | Ident { Expr.VarExpr $1 }
    | LBrace RBrace { Expr.ArrayExpr { elements = [] } }
    | LBrace expr_list RBrace { Expr.ArrayExpr { elements = $2 } }
    | Ident LBracket expr RBracket { Expr.IndexExpr { array = Expr.VarExpr $1; index = $3 } }
    | Ident LBracket expr Colon expr RBracket { Expr.SliceExpr { array = Expr.VarExpr $1; start = $3; end_ = $5 } }

expr_list:
    | expr Comma expr_list { $1 :: $3 }
    | expr { [$1] }
    | { [] }

argument_list:
    | expr Comma argument_list { $1 :: $3 }
    | expr { [$1] }
    | { [] }

class_body:
    | class_member class_body { (fst $1 @ fst $2, snd $1 @ snd $2) }
    | class_member { (fst $1, snd $1) }

class_member:
    | Var Ident Colon type_expr Semi { ([{ Stmt.name = $2; param_type = $4 }], []) }
    | FunctionDeclStmt { ([], [$1]) }

ImportStmt:
    | Import String { Stmt.ImportStmt { module_name = $2 } }

ExportStmt:
    | Export Ident { Stmt.ExportStmt { identifier = $2 } }

ClassDeclStmt:
    | Class Ident LBrace class_body RBrace { Stmt.ClassDeclStmt { name = $2; properties = fst $4; methods = snd $4 } }

ForStmt:
    | For LParen stmt_opt Semi expr_opt Semi stmt_opt RParen LBrace stmt_list RBrace { let default_condition = Expr.VarExpr "true" in Stmt.ForStmt { init = $3; condition = Option.value ~default:default_condition $5; increment = $7; body = Stmt.BlockStmt { body = $10 } } }

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

ReturnStmt:
    | Return expr { Stmt.ReturnStmt $2 }
    | Return { Stmt.ReturnStmt (Expr.VarExpr "") }

VarDeclStmt:
    | Var Ident Colon type_expr Assign expr {
        Stmt.VarDeclarationStmt { identifier = $2; constant = false; assigned_value = Some $6; explicit_type = $4; } }
    | Const Ident Colon type_expr Assign expr {
        Stmt.VarDeclarationStmt { identifier = $2; constant = true; assigned_value = Some $6; explicit_type = $4; } }
    | Var Ident Colon type_expr Assign Null {
        Stmt.VarDeclarationStmt { identifier = $2; constant = false; assigned_value = Some Expr.NullExpr; explicit_type = $4; } }
    | Const Ident Colon type_expr Assign Null {
        Stmt.VarDeclarationStmt { identifier = $2; constant = true; assigned_value = Some Expr.NullExpr; explicit_type = $4; } }

NewVarDeclStmt:
    | Var Ident Colon New Ident {
        Stmt.NewVarDeclarationStmt { identifier = $2; constant = false; assigned_value = None; arguments = [] }; }
    | Const Ident Colon New Ident {
        Stmt.NewVarDeclarationStmt { identifier = $2; constant = true; assigned_value = None; arguments = [] }; } 