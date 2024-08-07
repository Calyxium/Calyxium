package ast

import "plutonium/helpers"

type Stmt interface {
	stmt()
}

type Expr interface {
	expr()
}

type Type interface {
	_type()
}

func ExpectExpr[T Expr](Expr Expr) T {
	return helpers.ExpectType[T](Expr)
}

func ExpectStmt[T Stmt](expr Stmt) T {
	return helpers.ExpectType[T](expr)
}
