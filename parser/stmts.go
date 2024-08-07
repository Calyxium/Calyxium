package parser

import (
	"plutonium/ast"
	"plutonium/lexer"
)

func ParseStmt(Parse *Parser) ast.Stmt {
	StmtFunction, exists := StmtLu[Parse.CurrentTokenType()]

	if exists {
		return StmtFunction(Parse)
	}

	Expression := ParseExpr(Parse, DEFAULT_BP)
	Parse.Expect(lexer.SEMI_COLON)

	return ast.ExpressionStmt{
		Expression: Expression,
	}
}

func ParseVarDeclStmt(Parse *Parser) ast.Stmt {
	IsConstant := Parse.advance().Type == lexer.KEYWORDS_CONST
	VarName := Parse.ExpectError(lexer.IDENTIFIER, "Inside variable decleration expected to find variable name").Literal

	var DataType string
	switch Parse.advance().Type {
	case lexer.TYPE_INT:
		DataType = ast.TypeInt
	case lexer.TYPE_FLOAT:
		DataType = ast.TypeFloat
	case lexer.TYPE_STRING:
		DataType = ast.TypeString
	case lexer.TYPE_BOOLEAN:
		DataType = ast.TypeBool
	default:
		Parse.ExpectError(lexer.ERROR, "Expected a valid type")
	}

	Parse.Expect(lexer.ASSIGN)
	assignedValue := ParseExpr(Parse, ASSINGMENT)
	Parse.Expect(lexer.SEMI_COLON)
	return ast.VarDeclStmt{
		IsConstant:    IsConstant,
		VariableName:  VarName,
		AssignedValue: assignedValue,
		DataType:      DataType,
	}
}
