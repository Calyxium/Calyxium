package parser

import (
	"fmt"
	"plutonium/ast"
	"plutonium/lexer"
	"strconv"
)

func ParseExpr(Parse *Parser, BindingPower BindingPower) ast.Expr {
	TokenType := Parse.CurrentTokenType()
	NudFunction, exists := NudLu[TokenType]

	if !exists {
		panic(fmt.Sprintf("Nud handler expected for token %v\n", lexer.TokenTypeToString(TokenType)))
	}

	Left := NudFunction(Parse)

	for BindingPowerLu[Parse.CurrentTokenType()] > BindingPower {
		TokenType = Parse.CurrentTokenType()
		LedFunction, exists := LedLu[TokenType]

		if !exists {
			panic(fmt.Sprintf("Led handler expected for token %v\n", lexer.TokenTypeToString(TokenType)))
		}

		Left = LedFunction(Parse, Left, BindingPower)
	}

	return Left
}

func ParsePrimaryExpr(Parse *Parser) ast.Expr {
	switch Parse.CurrentTokenType() {
	case lexer.TYPE_INT:
		number, _ := strconv.ParseFloat(Parse.advance().Literal, 64)
		return ast.NumberExpr{
			Value: number,
		}
	case lexer.TYPE_STRING:
		return ast.StringExpr{
			Value: Parse.advance().Literal,
		}
	case lexer.IDENTIFIER:
		return ast.IdentExpr{
			Value: Parse.advance().Literal,
		}
	default:
		panic(fmt.Sprintf("Cannot create Primary Expression from %v\n", lexer.TokenTypeToString(Parse.CurrentTokenType())))
	}
}

func ParseBinaryExpr(Parse *Parser, Left ast.Expr, BindingPower BindingPower) ast.Expr {
	OperatorToken := Parse.advance()
	Right := ParseExpr(Parse, BindingPower)

	return ast.BinaryExpr{
		Left:     Left,
		Operator: OperatorToken,
		Right:    Right,
	}
}
