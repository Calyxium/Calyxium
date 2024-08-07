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
	Assigne  Expr
	Operator lexer.Token
	RHSValue Expr
}

func (Node AssignmentExpr) expr() {}

type StructInstantiationExpr struct {
	StructName string
	Properties map[string]Expr
}

func (Node StructInstantiationExpr) expr() {}

type ArrayInstantiationExpr struct {
	Underlying Type
	Contents   []Expr
}

func (Node ArrayInstantiationExpr) expr() {}
