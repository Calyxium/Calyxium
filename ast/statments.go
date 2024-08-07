package ast

type BlockStmt struct {
	Body []Stmt
}

func (Node BlockStmt) stmt() {}

type ExpressionStmt struct {
	Expression Expr
}

func (Node ExpressionStmt) stmt() {}

type VarDeclStmt struct {
	VariableName  string
	IsConstant    bool
	AssignedValue Expr
	ExplicitType  Type
}

func (Node VarDeclStmt) stmt() {}

type StructProperty struct {
	IsStatic bool
	Type     Type
}

type StructMethod struct {
	IsStatic bool
	// Type     Type
}

type StructStmt struct {
	StructName string
	Properties map[string]StructProperty
	Methods    map[string]StructMethod
}

func (Node StructStmt) stmt() {}
