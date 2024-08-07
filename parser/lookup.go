package parser

import (
	"plutonium/ast"
	"plutonium/lexer"
)

type BindingPower int

const (
	DEFAULT_BP BindingPower = iota
	COMMA
	ASSINGMENT
	LOGICAL
	RELATIONAL
	ADDITIVE
	MULTIPLICATIVE
	UNARY
	CALL
	MEMBER
	PRIMARY
)

type StmtHandler func(Parse *Parser) ast.Stmt
type NudHandler func(Parse *Parser) ast.Expr
type LedHanlder func(Parse *Parser, Left ast.Expr, Bp BindingPower) ast.Expr

type StmtLookup map[lexer.TokenType]StmtHandler
type NudLookup map[lexer.TokenType]NudHandler
type LedLookup map[lexer.TokenType]LedHanlder
type BindingPowerLookup map[lexer.TokenType]BindingPower

var (
	BindingPowerLu = BindingPowerLookup{}
	NudLu          = NudLookup{}
	LedLu          = LedLookup{}
	StmtLu         = StmtLookup{}
)

func Led(Type lexer.TokenType, BindingPower BindingPower, LedFunction LedHanlder) {
	BindingPowerLu[Type] = BindingPower
	LedLu[Type] = LedFunction
}

func Nud(Type lexer.TokenType, BindingPower BindingPower, NudFunction NudHandler) {
	BindingPowerLu[Type] = PRIMARY
	NudLu[Type] = NudFunction
}

func Stmt(Type lexer.TokenType, StmtFunction StmtHandler) {
	BindingPowerLu[Type] = DEFAULT_BP
	StmtLu[Type] = StmtFunction
}

func CreateTokenLookup() {
	Led(lexer.LOGICAL_AND, LOGICAL, ParseBinaryExpr)
	Led(lexer.LOGICAL_OR, LOGICAL, ParseBinaryExpr)

	Led(lexer.LT, RELATIONAL, ParseBinaryExpr)
	Led(lexer.LESS_THAN_EQUALS, RELATIONAL, ParseBinaryExpr)
	Led(lexer.GT, RELATIONAL, ParseBinaryExpr)
	Led(lexer.GREATER_THAN_EQUALS, RELATIONAL, ParseBinaryExpr)
	Led(lexer.ASSIGN, RELATIONAL, ParseBinaryExpr)
	Led(lexer.NOT_EQUALS, RELATIONAL, ParseBinaryExpr)
	Led(lexer.PLUS_ASSIGN, RELATIONAL, ParseBinaryExpr)
	Led(lexer.MINUS_ASSIGN, RELATIONAL, ParseBinaryExpr)
	Led(lexer.MULTIPLY_ASSIGN, RELATIONAL, ParseBinaryExpr)
	Led(lexer.DIVIDE_ASSIGN, RELATIONAL, ParseBinaryExpr)

	Led(lexer.PLUS, ADDITIVE, ParseBinaryExpr)
	Led(lexer.MINUS, ADDITIVE, ParseBinaryExpr)
	Led(lexer.MULTIPLY, ADDITIVE, ParseBinaryExpr)
	Led(lexer.DIVIDE, ADDITIVE, ParseBinaryExpr)

	Nud(lexer.TYPE_INT, PRIMARY, ParsePrimaryExpr)
	Nud(lexer.TYPE_FLOAT, PRIMARY, ParsePrimaryExpr)
	Nud(lexer.TYPE_STRING, PRIMARY, ParsePrimaryExpr)
	Nud(lexer.TYPE_BOOLEAN, PRIMARY, ParsePrimaryExpr)
	Nud(lexer.IDENTIFIER, PRIMARY, ParsePrimaryExpr)

	Stmt(lexer.KEYWORDS_CONST, ParseVarDeclStmt)
	Stmt(lexer.KEYWORDS_VAR, ParseVarDeclStmt)

}
