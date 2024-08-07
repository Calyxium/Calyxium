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

func Nud(Type lexer.TokenType, NudFunction NudHandler) {
	NudLu[Type] = NudFunction
}

func Stmt(Type lexer.TokenType, StmtFunction StmtHandler) {
	BindingPowerLu[Type] = DEFAULT_BP
	StmtLu[Type] = StmtFunction
}

func CreateTokenLookup() {
	// Assignment
	Led(lexer.ASSIGN, ASSINGMENT, ParseAssignmentExpr)
	Led(lexer.PLUS_ASSIGN, ASSINGMENT, ParseAssignmentExpr)
	Led(lexer.MINUS_ASSIGN, ASSINGMENT, ParseAssignmentExpr)
	Led(lexer.MULTIPLY_ASSIGN, ASSINGMENT, ParseAssignmentExpr)
	Led(lexer.DIVIDE_ASSIGN, ASSINGMENT, ParseAssignmentExpr)

	// Logical
	Led(lexer.LOGICAL_AND, LOGICAL, ParseBinaryExpr)
	Led(lexer.LOGICAL_OR, LOGICAL, ParseBinaryExpr)

	// Relational
	Led(lexer.LT, RELATIONAL, ParseBinaryExpr)
	Led(lexer.LESS_THAN_EQUALS, RELATIONAL, ParseBinaryExpr)
	Led(lexer.GT, RELATIONAL, ParseBinaryExpr)
	Led(lexer.GREATER_THAN_EQUALS, RELATIONAL, ParseBinaryExpr)
	Led(lexer.ASSIGN, RELATIONAL, ParseBinaryExpr)
	Led(lexer.NOT_EQUALS, RELATIONAL, ParseBinaryExpr)

	// Additive & Multiplicitave
	Led(lexer.PLUS, ADDITIVE, ParseBinaryExpr)
	Led(lexer.MINUS, ADDITIVE, ParseBinaryExpr)
	Led(lexer.MULTIPLY, ADDITIVE, ParseBinaryExpr)
	Led(lexer.DIVIDE, ADDITIVE, ParseBinaryExpr)

	// Literals & Symbols
	Nud(lexer.TYPE_INT, ParsePrimaryExpr)
	Nud(lexer.TYPE_FLOAT, ParsePrimaryExpr)
	Nud(lexer.TYPE_STRING, ParsePrimaryExpr)
	Nud(lexer.TYPE_BOOLEAN, ParsePrimaryExpr)
	Nud(lexer.IDENTIFIER, ParsePrimaryExpr)
	Nud(lexer.OPEN_PAREN, ParseGroupingExpr)
	Nud(lexer.MINUS, ParsePrefixExpr)

	// Member / Computed // Call
	Led(lexer.DOT, MEMBER, ParseMemberExpr)
	Led(lexer.OPEN_BRACKET, MEMBER, ParseMemberExpr)
	Led(lexer.OPEN_PAREN, MEMBER, ParseMemberExpr)

	//Led(lexer.OPEN_BRACE, CALL, ParseStructInstantionsExpr)
	Nud(lexer.OPEN_BRACKET, ParseArrayInstantionsExpr)
	Nud(lexer.KEYWORDS_FUNCTION, ParseFunctionExpr)

	Stmt(lexer.OPEN_BRACE, ParseBlockStmt)
	Stmt(lexer.KEYWORDS_FUNCTION, ParseFunctionDeclStmt)
	Stmt(lexer.KEYWORDS_IF, ParseIfDeclStmt)
	Stmt(lexer.KEYWORDS_IMPORT, ParseImportStmt)
	Stmt(lexer.KEYWORDS_CONST, ParseVarDeclStmt)
	Stmt(lexer.KEYWORDS_VAR, ParseVarDeclStmt)
	Stmt(lexer.KEYWORDS_CLASS, ParseClassDeclStmt)
	Stmt(lexer.KEYWORDS_RETURN, ParseReturnStmt)

}
