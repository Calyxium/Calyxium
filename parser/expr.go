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
	OperatorToken := Parse.advance()
	Rhs := ParseExpr(Parse, BindingPower)

	return ast.AssignmentExpr{
		Operator:      OperatorToken,
		Assigne:       Left,
		AssignedValue: Rhs,
	}
}

func ParseRangeExpr(Parse *Parser, Left ast.Expr, BindingPower BindingPower) ast.Expr {
	Parse.advance()

	return ast.RangeExpr{
		Lower: Left,
		Upper: ParseExpr(Parse, BindingPower),
	}
}

func ParseGroupingExpr(Parse *Parser) ast.Expr {
	Parse.advance()
	Expr := ParseExpr(Parse, DEFAULT_BP)
	Parse.Expect(lexer.CLOSE_PAREN)
	return Expr
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

func ParseMemberExpr(Parse *Parser, Left ast.Expr, BindingPower BindingPower) ast.Expr {
	isComputed := Parse.advance().Type == lexer.OPEN_BRACKET

	if isComputed {
		Rhs := ParseExpr(Parse, BindingPower)
		Parse.Expect(lexer.CLOSE_BRACKET)
		return ast.ComputedExpr{
			Member:   Left,
			Property: Rhs,
		}
	}

	return ast.MemberExpr{
		Member:   Left,
		Property: Parse.Expect(lexer.IDENTIFIER).Literal,
	}
}

func ParseCallExpr(Parse *Parser, Left ast.Expr, BindingPower BindingPower) ast.Expr {
	Parse.advance()
	Arguments := make([]ast.Expr, 0)

	for Parse.HasToken() && Parse.CurrentTokenType() != lexer.CLOSE_PAREN {
		Arguments = append(Arguments, ParseExpr(Parse, ASSINGMENT))

		if !Parse.CurrentToken().IsOneOfMany(lexer.EOF, lexer.CLOSE_PAREN) {
			Parse.Expect(lexer.COMMA)
		}
	}

	Parse.Expect(lexer.CLOSE_PAREN)
	return ast.CallExpr{
		Method:    Left,
		Arguments: Arguments,
	}
}

func ParseFunctionExpr(Parse *Parser) ast.Expr {
	Parse.Expect(lexer.KEYWORDS_FUNCTION)
	FunctionParams, ReturnType, FunctionBody := ParseFunctionParamsAndBody(Parse)

	return ast.FunctionExpr{
		Parameters: FunctionParams,
		ReturnType: ReturnType,
		Body:       FunctionBody,
	}
}
