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
