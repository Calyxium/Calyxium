package parser

import (
	"fmt"
	"plutonium/ast"
	"plutonium/lexer"
)

func ExprStmt(Parse *Parser) ast.Stmt {
	Expression := ParseExpr(Parse, DEFAULT_BP)
	Parse.Expect(lexer.SEMI_COLON)
	return ast.ExpressionStmt{
		Expression: Expression,
	}
}

func ParseStmt(Parse *Parser) ast.Stmt {
	StmtFunction, exists := StmtLu[Parse.CurrentTokenType()]

	if exists {
		return StmtFunction(Parse)
	}

	return ExprStmt(Parse)
}

func ParseVarDeclStmt(Parse *Parser) ast.Stmt {
	var ExplicitType ast.Type
	startToken := Parse.advance().Type
	isConstant := startToken == lexer.KEYWORDS_CONST
	symbolName := Parse.ExpectError(lexer.IDENTIFIER,
		fmt.Sprintf("Following %s expected variable name however instead recieved %s instead\n",
			lexer.TokenTypeToString(startToken), lexer.TokenTypeToString(Parse.CurrentTokenType())))

	if Parse.CurrentTokenType() == lexer.COLON {
		Parse.Expect(lexer.COLON)
		ExplicitType = ParseType(Parse, DEFAULT_BP)
	}

	var assignmentValue ast.Expr
	if Parse.CurrentTokenType() != lexer.SEMI_COLON {
		Parse.Expect(lexer.ASSIGN)
		assignmentValue = ParseExpr(Parse, ASSINGMENT)
	} else if ExplicitType == nil {
		panic("Missing explicit type for variable declaration.")
	}

	if isConstant && assignmentValue == nil {
		panic("Cannot define constant variable without providing default value.")
	}

	return ast.VarDeclarationStmt{
		Constant:      isConstant,
		Identifier:    symbolName.Literal,
		AssignedValue: assignmentValue,
		ExplicitType:  ExplicitType,
	}
}

func ParseBlockStmt(Parse *Parser) ast.Stmt {
	Parse.Expect(lexer.OPEN_BRACE)
	Body := []ast.Stmt{}

	for Parse.HasToken() && Parse.CurrentTokenType() != lexer.CLOSE_BRACE {
		Body = append(Body, ParseStmt(Parse))

		if Parse.CurrentTokenType() != lexer.CLOSE_BRACE {
			Parse.Expect(lexer.SEMI_COLON)
		}
	}

	Parse.Expect(lexer.CLOSE_BRACE)
	return ast.BlockStmt{
		Body: Body,
	}
}

func ParseFunctionParamsAndBody(Parse *Parser) ([]ast.Parameter, ast.Type, []ast.Stmt) {
	FunctionParams := make([]ast.Parameter, 0)

	Parse.Expect(lexer.OPEN_PAREN)
	for Parse.HasToken() && Parse.CurrentTokenType() != lexer.CLOSE_PAREN {
		ParamName := Parse.Expect(lexer.IDENTIFIER).Literal
		Parse.Expect(lexer.COLON)
		ParamType := ParseType(Parse, DEFAULT_BP)

		FunctionParams = append(FunctionParams, ast.Parameter{
			Name: ParamName,
			Type: ParamType,
		})

		if !Parse.CurrentToken().IsOneOfMany(lexer.CLOSE_PAREN, lexer.EOF) {
			Parse.Expect(lexer.COMMA)
		}
	}

	Parse.Expect(lexer.CLOSE_PAREN)
	var ReturnType ast.Type

	if Parse.CurrentTokenType() == lexer.COLON {
		Parse.advance()
		ReturnType = ParseType(Parse, DEFAULT_BP)
	}

	FunctionBody := ast.ExpectStmt[ast.BlockStmt](ParseBlockStmt(Parse)).Body

	return FunctionParams, ReturnType, FunctionBody
}

func ParseFunctionDeclStmt(Parse *Parser) ast.Stmt {
	Parse.advance()
	FunctionName := Parse.Expect(lexer.IDENTIFIER).Literal
	FunctionParams, ReturnType, FunctionBody := ParseFunctionParamsAndBody(Parse)

	return ast.FunctionDeclarationStmt{
		Parameters: FunctionParams,
		ReturnType: ReturnType,
		Body:       FunctionBody,
		Name:       FunctionName,
	}
}

func ParseIfDeclStmt(Parse *Parser) ast.Stmt {
	Parse.advance()
	Condition := ParseExpr(Parse, ASSINGMENT)
	Consequent := ParseBlockStmt(Parse)

	var Alternate ast.Stmt
	if Parse.CurrentTokenType() == lexer.KEYWORDS_ELSE {
		Parse.advance()

		if Parse.CurrentTokenType() == lexer.KEYWORDS_IF {
			Alternate = ParseIfDeclStmt(Parse)
		} else {
			Alternate = ParseBlockStmt(Parse)
		}
	}

	return ast.IfStmt{
		Condition:  Condition,
		Consequent: Consequent,
		Alternate:  Alternate,
	}
}

func ParseImportStmt(Parse *Parser) ast.Stmt {
	Parse.advance()
	var ImportFrom string
	ImportName := Parse.Expect(lexer.IDENTIFIER).Literal

	if Parse.CurrentTokenType() == lexer.KEYWORDS_IMPORT {
		Parse.advance()
		ImportFrom = Parse.Expect(lexer.TYPE_STRING).Literal
	} else {
		ImportFrom = ImportName
	}
	Parse.Expect(lexer.SEMI_COLON)
	return ast.ImportStmt{
		Name: ImportName,
		From: ImportFrom,
	}
}

func ParseClassDeclStmt(Parse *Parser) ast.Stmt {
	Parse.advance()
	ClassName := Parse.Expect(lexer.IDENTIFIER).Literal
	ClassBody := ParseBlockStmt(Parse)

	return ast.ClassDeclarationStmt{
		Name: ClassName,
		Body: ast.ExpectStmt[ast.BlockStmt](ClassBody).Body,
	}
}

func ParseReturnStmt(Parse *Parser) ast.Stmt {
	Parse.advance()

	var ReturnValue ast.Expr
	if Parse.CurrentTokenType() != lexer.SEMI_COLON {
		ReturnValue = ParseExpr(Parse, DEFAULT_BP)
	}

	Parse.Expect(lexer.SEMI_COLON)

	return ast.ReturnStmt{
		Value: ReturnValue,
	}
}
