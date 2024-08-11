package ast

import (
	"calyxium/lexer"
)

// --------------------
// Literal Expressions
// --------------------

type IntExpr struct {
	Value int64
}

func (n IntExpr) expr() {}

type FloatExpr struct {
	Value float64
}

func (n FloatExpr) expr() {}

type StringExpr struct {
	Value string
}

func (n StringExpr) expr() {}

type SymbolExpr struct {
	Value string
}

func (n SymbolExpr) expr() {}

// --------------------
// Complex Expressions
// --------------------

type BinaryExpr struct {
	Left     Expr
	Operator lexer.Token
	Right    Expr
}

func (n BinaryExpr) expr() {}

type AssignmentExpr struct {
	Assigne       Expr
	AssignedValue Expr
}

func (n AssignmentExpr) expr() {}

type PrefixExpr struct {
	Operator lexer.Token
	Right    Expr
}

func (n PrefixExpr) expr() {}

type MemberExpr struct {
	Member   Expr
	Property string
}

func (n MemberExpr) expr() {}

type StructType struct {
	Name    string
	Members map[string]Type
}

func (st StructType) _type() {}

func (st StructType) GetMemberType(memberName string) (Type, bool) {
	memberType, exists := st.Members[memberName]
	return memberType, exists
}

type CallExpr struct {
	Method    Expr
	Arguments []Expr
}

func (n CallExpr) expr() {}

type ComputedExpr struct {
	Member   Expr
	Property Expr
}

func (n ComputedExpr) expr() {}

type RangeExpr struct {
	Lower Expr
	Upper Expr
}

func (n RangeExpr) expr() {}

type FunctionExpr struct {
	Parameters []Parameter
	Body       []Stmt
	ReturnType Type
}

func (n FunctionExpr) expr() {}

func (f FunctionExpr) _type() {}

type ArrayLiteral struct {
	Contents []Expr
}

func (n ArrayLiteral) expr() {}

type NewExpr struct {
	Instantiation CallExpr
}

func (n NewExpr) expr() {}

type BooleanExpr struct {
	IsTrue bool
}

func (n BooleanExpr) expr() {}
