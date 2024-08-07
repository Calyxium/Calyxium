package parser

import (
	"fmt"
	"plutonium/ast"
	"plutonium/helpers"
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

		Left = LedFunction(Parse, Left, BindingPowerLu[Parse.CurrentTokenType()])
	}

	return Left
}

func ParsePrimaryExpr(Parse *Parser) ast.Expr {
	switch Parse.CurrentTokenType() {
	case lexer.TYPE_FLOAT:
		number, _ := strconv.ParseFloat(Parse.advance().Literal, 64)
		return ast.NumberExpr{
			Value: number,
		}
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

func ParsePrefixExpr(Parse *Parser) ast.Expr {
	Operator := Parse.advance()
	Rhs := ParseExpr(Parse, DEFAULT_BP)

	return ast.PrefixExpr{
		Operator:  Operator,
		RightExpr: Rhs,
	}
}

func ParseAssignmentExpr(Parse *Parser, Left ast.Expr, BindingPower BindingPower) ast.Expr {
	Operator := Parse.advance()
	Rhs := ParseExpr(Parse, BindingPower)

	return ast.AssignmentExpr{
		Operator: Operator,
		RHSValue: Rhs,
		Assigne:  Left,
	}
}

func ParseGroupingExpr(Parse *Parser) ast.Expr {
	Parse.advance()
	Expr := ParseExpr(Parse, DEFAULT_BP)
	Parse.Expect(lexer.CLOSE_PAREN)
	return Expr
}

func ParseStructInstantionsExpr(Parse *Parser, Left ast.Expr, BindingPower BindingPower) ast.Expr {
	var StructName = helpers.ExpectType[ast.IdentExpr](Left).Value
	var Properties = map[string]ast.Expr{}

	Parse.Expect(lexer.OPEN_BRACE)

	for Parse.HasToken() && Parse.CurrentTokenType() != lexer.CLOSE_BRACE {
		PropertyName := Parse.Expect(lexer.IDENTIFIER).Literal
		Parse.Expect(lexer.COLON)
		Expr := ParseExpr(Parse, LOGICAL)

		Properties[PropertyName] = Expr

		if Parse.CurrentTokenType() != lexer.CLOSE_BRACE {
			Parse.Expect(lexer.COMMA)
		}
	}

	Parse.Expect(lexer.CLOSE_BRACE)
	return ast.StructInstantiationExpr{
		StructName: StructName,
		Properties: Properties,
	}
}

func ParseArrayInstantionsExpr(Parse *Parser) ast.Expr {
	var UnderlyingType ast.Type
	var Contents = []ast.Expr{}

	Parse.Expect(lexer.OPEN_BRACKET)
	Parse.Expect(lexer.CLOSE_BRACKET)

	UnderlyingType = ParseType(Parse, DEFAULT_BP)

	Parse.Expect(lexer.OPEN_BRACE)
	for Parse.HasToken() && Parse.CurrentTokenType() != lexer.CLOSE_BRACE {
		Contents = append(Contents, ParseExpr(Parse, LOGICAL))

		if Parse.CurrentTokenType() != lexer.CLOSE_BRACE {
			Parse.Expect(lexer.COMMA)
		}
	}

	Parse.Expect(lexer.CLOSE_BRACE)
	return ast.ArrayInstantiationExpr{
		Underlying: UnderlyingType,
		Contents:   Contents,
	}
}
