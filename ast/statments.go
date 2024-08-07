package ast

const (
	TypeInt    = "int"
	TypeFloat  = "float"
	TypeString = "string"
	TypeBool   = "bool"
)

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
	DataType      string
	// ExplictitType Type
}

func (Node VarDeclStmt) stmt() {}
