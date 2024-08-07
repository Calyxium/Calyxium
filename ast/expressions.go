package ast

import "plutonium/lexer"

type NumberExpr struct {
	Value float64
}

func (Node NumberExpr) expr() {}

type StringExpr struct {
	Value string
}

func (Node StringExpr) expr() {}

type IdentExpr struct {
	Value string
}

func (Node IdentExpr) expr() {}

type BinaryExpr struct {
	Left     Expr
	Operator lexer.Token
	Right    Expr
}

func (Node BinaryExpr) expr() {}

type PrefixExpr struct {
	Operator  lexer.Token
	RightExpr Expr
}

func (Node PrefixExpr) expr() {}

type AssignmentExpr struct {
	Assigne       Expr
	AssignedValue Expr
}

func (Node AssignmentExpr) expr() {}

type MemberExpr struct {
	Member   Expr
	Property string
}

func (Node MemberExpr) expr() {}

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

type ArrayInstantiationExpr struct {
	Underlying Type
	Contents   []Expr
}

func (Node ArrayInstantiationExpr) expr() {}

type NewExpr struct {
	Instantiation CallExpr
}

func (n NewExpr) expr() {}
