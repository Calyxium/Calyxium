package ast

type BlockStmt struct {
	Body []Stmt
}

func (b BlockStmt) stmt() {}

type VarDeclarationStmt struct {
	Identifier    string
	Constant      bool
	AssignedValue Expr
	ExplicitType  Type
}

func (n VarDeclarationStmt) stmt() {}

type ExpressionStmt struct {
	Expression Expr
}

func (n ExpressionStmt) stmt() {}

type Parameter struct {
	Name string
	Type Type
}

type FunctionDeclarationStmt struct {
	Parameters []Parameter
	Name       string
	Body       []Stmt
	ReturnType Type
}

func (n FunctionDeclarationStmt) stmt() {}

type IfStmt struct {
	Condition  Expr
	Consequent Stmt
	Alternate  Stmt
}

func (n IfStmt) stmt() {}

type ImportStmt struct {
	Name string
	From string
}

func (n ImportStmt) stmt() {}

type ClassDeclarationStmt struct {
	Name string
	Body []Stmt
}

func (n ClassDeclarationStmt) stmt() {}

type ReturnStmt struct {
	Value Expr
}

func (n ReturnStmt) stmt() {}

type ForStmt struct {
	Init      Expr   // Initialization expression (e.g., 'var i = 0')
	Condition Expr   // Loop condition (e.g., 'i < 10')
	Post      Expr   // Post-expression (e.g., 'i++')
	Body      []Stmt // Body of the loop
}

func (n ForStmt) stmt() {}
