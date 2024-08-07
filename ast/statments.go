package ast

type BlockStmt struct {
	Body []Stmt
}

func (Node BlockStmt) stmt() {}

type ExpressionStmt struct {
	Expression Expr
}

func (Node ExpressionStmt) stmt() {}

type VarDeclarationStmt struct {
	Identifier    string
	Constant      bool
	AssignedValue Expr
	ExplicitType  Type
}

func (Node VarDeclarationStmt) stmt() {}

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
