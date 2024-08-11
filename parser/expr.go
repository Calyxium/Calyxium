package parser

import (
	"calyxium/ast"
	"calyxium/lexer"
	"fmt"
	"strconv"
)

func ParseExpr(Parse *Parser, bp binding_power) ast.Expr {
	tokenKind := Parse.currentTokenKind()
	nud_fn, exists := NudLu[tokenKind]

	if !exists {
		fmt.Print(fmt.Errorf("NUD Handler expected for token %s", lexer.TokenTypeToString(tokenKind)))
	}

	left := nud_fn(Parse)

	for BindingPowerLu[Parse.currentTokenKind()] > bp {
		tokenKind = Parse.currentTokenKind()
		led_fn, exists := LedLu[tokenKind]

		if !exists {
			fmt.Print(fmt.Errorf("LED Handler expected for token %s", lexer.TokenTypeToString(tokenKind)))
		}

		left = led_fn(Parse, left, bp)
	}

	return left
}

func ParsePrefixExpr(Parse *Parser) ast.Expr {
	operatorToken := Parse.advance()
	expr := ParseExpr(Parse, unary)

	return ast.PrefixExpr{
		Operator: operatorToken,
		Right:    expr,
	}
}

func ParseAssignmentExpr(Parse *Parser, left ast.Expr, bp binding_power) ast.Expr {
	Parse.advance()
	rhs := ParseExpr(Parse, bp)

	return ast.AssignmentExpr{
		Assigne:       left,
		AssignedValue: rhs,
	}
}

func ParseBinaryExpr(Parse *Parser, left ast.Expr, bp binding_power) ast.Expr {
	operatorToken := Parse.advance()
	right := ParseExpr(Parse, defalt_bp)

	return ast.BinaryExpr{
		Left:     left,
		Operator: operatorToken,
		Right:    right,
	}
}

func ParsePrimaryExpr(Parse *Parser) ast.Expr {
	switch Parse.currentTokenKind() {
	case lexer.TYPE_FLOAT:
		number, _ := strconv.ParseFloat(Parse.advance().Literal, 64)
		return ast.FloatExpr{
			Value: number,
		}
	case lexer.TYPE_INT:
		number, _ := strconv.ParseInt(Parse.advance().Literal, 0, 64)
		return ast.IntExpr{
			Value: number,
		}
	case lexer.STRING:
		return ast.StringExpr{
			Value: Parse.advance().Literal,
		}
	case lexer.IDENTIFIER:
		return ast.SymbolExpr{
			Value: Parse.advance().Literal,
		}
	case lexer.KEYWORDS_TRUE:
		Parse.advance()
		return ast.BooleanExpr{
			IsTrue: true,
		}
	case lexer.KEYWORDS_FALSE:
		Parse.advance()
		return ast.BooleanExpr{
			IsTrue: false,
		}
	default:
		fmt.Print(fmt.Errorf("cannot create primary_expr from %s", lexer.TokenTypeToString(Parse.currentTokenKind())))
	}

	return nil
}

func ParseMemberExpr(Parse *Parser, left ast.Expr, bp binding_power) ast.Expr {
	isComputed := Parse.advance().Type == lexer.OPEN_BRACKET

	if isComputed {
		rhs := ParseExpr(Parse, bp)
		Parse.expect(lexer.CLOSE_BRACKET)
		return ast.ComputedExpr{
			Member:   left,
			Property: rhs,
		}
	}

	return ast.MemberExpr{
		Member:   left,
		Property: Parse.expect(lexer.IDENTIFIER).Literal,
	}
}

func ParseArrayLiteralExpr(Parse *Parser) ast.Expr {
	Parse.expect(lexer.OPEN_BRACKET)
	arrayContents := make([]ast.Expr, 0)

	for Parse.hasTokens() && Parse.currentTokenKind() != lexer.CLOSE_BRACKET {
		arrayContents = append(arrayContents, ParseExpr(Parse, logical))

		if !Parse.currentToken().IsOneOfMany(lexer.EOF, lexer.CLOSE_BRACKET) {
			Parse.expect(lexer.COMMA)
		}
	}

	Parse.expect(lexer.CLOSE_BRACKET)

	return ast.ArrayLiteral{
		Contents: arrayContents,
	}
}

func ParseGroupingExpr(Parse *Parser) ast.Expr {
	Parse.expect(lexer.OPEN_PAREN)
	expr := ParseExpr(Parse, defalt_bp)
	Parse.expect(lexer.OPEN_PAREN)
	return expr
}

func ParseCallExpr(Parse *Parser, left ast.Expr, bp binding_power) ast.Expr {
	Parse.advance()
	arguments := make([]ast.Expr, 0)

	for Parse.hasTokens() && Parse.currentTokenKind() != lexer.CLOSE_PAREN {
		arguments = append(arguments, ParseExpr(Parse, assignment))

		if !Parse.currentToken().IsOneOfMany(lexer.EOF, lexer.CLOSE_PAREN) {
			Parse.expect(lexer.COMMA)
		}
	}

	Parse.expect(lexer.CLOSE_PAREN)
	return ast.CallExpr{
		Method:    left,
		Arguments: arguments,
	}
}

func ParseFunctionExpr(Parse *Parser) ast.Expr {
	Parse.expect(lexer.KEYWORDS_FUNCTION)
	functionParams, returnType, functionBody := ParseFunctionParamsAndBody(Parse)

	return ast.FunctionExpr{
		Parameters: functionParams,
		ReturnType: returnType,
		Body:       functionBody,
	}
}
