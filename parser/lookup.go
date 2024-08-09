package parser

import (
	"plutonium/ast"
	"plutonium/lexer"
)

type binding_power int

const (
	defalt_bp binding_power = iota
	comma
	assignment
	logical
	relational
	additive
	multiplicative
	unary
	call
	member
	primary
)

type StmtHandler func(Parse *Parser) ast.Stmt
type NudHandler func(Parse *Parser) ast.Expr
type LedHandler func(Parse *Parser, left ast.Expr, bp binding_power) ast.Expr

type StmtLookup map[lexer.TokenType]StmtHandler
type NudLookup map[lexer.TokenType]NudHandler
type LedLookup map[lexer.TokenType]LedHandler
type BindingPowerLookup map[lexer.TokenType]binding_power

var BindingPowerLu = BindingPowerLookup{}
var NudLu = NudLookup{}
var LedLu = LedLookup{}
var StmtLu = StmtLookup{}

func Led(kind lexer.TokenType, bp binding_power, Led_fn LedHandler) {
	BindingPowerLu[kind] = bp
	LedLu[kind] = Led_fn
}

func Nud(kind lexer.TokenType, bp binding_power, Nud_fn NudHandler) {
	BindingPowerLu[kind] = primary
	NudLu[kind] = Nud_fn
}

func Stmt(kind lexer.TokenType, Stmt_fn StmtHandler) {
	BindingPowerLu[kind] = defalt_bp
	StmtLu[kind] = Stmt_fn
}

func CreateTokenLookup() {
	// Assignment
	Led(lexer.ASSIGN, assignment, ParseAssignmentExpr)
	Led(lexer.PLUS_ASSIGN, assignment, ParseAssignmentExpr)
	Led(lexer.MINUS_ASSIGN, assignment, ParseAssignmentExpr)

	// Logical
	Led(lexer.LOGICAL_AND, logical, ParseBinaryExpr)
	Led(lexer.LOGICAL_OR, logical, ParseBinaryExpr)

	// Relational
	Led(lexer.LT, relational, ParseBinaryExpr)
	Led(lexer.LESS_THAN_EQUALS, relational, ParseBinaryExpr)
	Led(lexer.GT, relational, ParseBinaryExpr)
	Led(lexer.GREATER_THAN_EQUALS, relational, ParseBinaryExpr)
	Led(lexer.EQUALS, relational, ParseBinaryExpr)
	Led(lexer.NOT_EQUALS, relational, ParseBinaryExpr)

	// Additive & Multiplicitave
	Led(lexer.PLUS, additive, ParseBinaryExpr)
	Led(lexer.MINUS, additive, ParseBinaryExpr)
	Led(lexer.DIVIDE, multiplicative, ParseBinaryExpr)
	Led(lexer.MULTIPLY, multiplicative, ParseBinaryExpr)

	// Literals & Symbols
	Nud(lexer.TYPE_INT, primary, ParsePrimaryExpr)
	Nud(lexer.TYPE_FLOAT, primary, ParsePrimaryExpr)
	Nud(lexer.KEYWORDS_TRUE, primary, ParsePrimaryExpr)
	Nud(lexer.KEYWORDS_FALSE, primary, ParsePrimaryExpr)
	Nud(lexer.STRING, primary, ParsePrimaryExpr)
	Nud(lexer.IDENTIFIER, primary, ParsePrimaryExpr)

	// Unary/Prefix
	Nud(lexer.MINUS, unary, ParsePrefixExpr)
	Nud(lexer.NOT, unary, ParsePrefixExpr)
	Nud(lexer.OPEN_BRACKET, primary, ParseArrayLiteralExpr)

	// Member / Computed // Call
	Led(lexer.DOT, member, ParseMemberExpr)
	Led(lexer.OPEN_BRACKET, member, ParseMemberExpr)
	Led(lexer.OPEN_PAREN, call, ParseCallExpr)

	// Grouping Expr
	Nud(lexer.OPEN_PAREN, defalt_bp, ParseGroupingExpr)
	Nud(lexer.KEYWORDS_FUNCTION, defalt_bp, ParseFunctionExpr)
	Nud(lexer.KEYOWRDS_NEW, defalt_bp, func(Parse *Parser) ast.Expr {
		Parse.advance()
		classInstantiation := ParseExpr(Parse, defalt_bp)

		return ast.NewExpr{
			Instantiation: ast.ExpectExpr[ast.CallExpr](classInstantiation),
		}
	})

	Stmt(lexer.OPEN_BRACE, ParseBlockStmt)
	Stmt(lexer.KEYWORDS_VAR, ParseVarDeclStmt)
	Stmt(lexer.KEYWORDS_CONST, ParseVarDeclStmt)
	Stmt(lexer.KEYWORDS_FUNCTION, ParseFunctionDeclaration)
	Stmt(lexer.KEYWORDS_IF, ParseIfStmt)
	Stmt(lexer.KEYWORDS_IMPORT, ParseImportStmt)
	Stmt(lexer.KEYWORDS_CLASS, ParseClassDeclStmt)
	Stmt(lexer.KEYWORDS_RETURN, ParseReturnStmt)
	Stmt(lexer.KEYWORDS_FOR, ParseForStmt)
}
