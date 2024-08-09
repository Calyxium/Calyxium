package parser

import (
	"fmt"

	"plutonium/ast"
	"plutonium/lexer"
)

func ParseStmt(Parse *Parser) ast.Stmt {
	StmtFunction, exists := StmtLu[Parse.currentTokenKind()]

	if exists {
		return StmtFunction(Parse)
	}

	return ParseExpressionStmt(Parse)
}

func ParseExpressionStmt(Parse *Parser) ast.ExpressionStmt {
	expression := ParseExpr(Parse, defalt_bp)
	Parse.expect(lexer.SEMI_COLON)

	return ast.ExpressionStmt{
		Expression: expression,
	}
}

func ParseBlockStmt(Parse *Parser) ast.Stmt {
	Parse.expect(lexer.OPEN_BRACE)
	body := []ast.Stmt{}

	for Parse.hasTokens() && Parse.currentTokenKind() != lexer.CLOSE_BRACE {
		body = append(body, ParseStmt(Parse))
	}

	Parse.expect(lexer.CLOSE_BRACE)
	return ast.BlockStmt{
		Body: body,
	}
}

func ParseVarDeclStmt(Parse *Parser) ast.Stmt {
	var explicitType ast.Type
	startToken := Parse.advance().Type
	isConstant := startToken == lexer.KEYWORDS_CONST
	symbolName := Parse.expectError(lexer.IDENTIFIER,
		fmt.Sprintf("Following %s expected variable name however instead recieved %s instead\n",
			lexer.TokenTypeToString(startToken), lexer.TokenTypeToString(Parse.currentTokenKind())))

	if Parse.currentTokenKind() == lexer.COLON {
		Parse.expect(lexer.COLON)
		explicitType = ParseType(Parse, defalt_bp)
	}

	var assignmentValue ast.Expr
	if Parse.currentTokenKind() != lexer.SEMI_COLON {
		Parse.expect(lexer.ASSIGN)
		assignmentValue = ParseExpr(Parse, assignment)
	} else if explicitType == nil {
		panic("Missing explicit type for variable declaration.")
	}

	Parse.expect(lexer.SEMI_COLON)

	if isConstant && assignmentValue == nil {
		panic("Cannot define constant variable without providing default value.")
	}

	return ast.VarDeclarationStmt{
		Constant:      isConstant,
		Identifier:    symbolName.Literal,
		AssignedValue: assignmentValue,
		ExplicitType:  explicitType,
	}
}

func ParseFunctionParamsAndBody(Parse *Parser) ([]ast.Parameter, ast.Type, []ast.Stmt) {
	functionParams := make([]ast.Parameter, 0)

	Parse.expect(lexer.OPEN_PAREN)
	for Parse.hasTokens() && Parse.currentTokenKind() != lexer.CLOSE_PAREN {
		paramName := Parse.expect(lexer.IDENTIFIER).Literal
		Parse.expect(lexer.COLON)
		paramType := ParseType(Parse, defalt_bp)

		functionParams = append(functionParams, ast.Parameter{
			Name: paramName,
			Type: paramType,
		})

		if !Parse.currentToken().IsOneOfMany(lexer.CLOSE_PAREN, lexer.EOF) {
			Parse.expect(lexer.COMMA)
		}
	}

	Parse.expect(lexer.CLOSE_PAREN)
	var returnType ast.Type

	if Parse.currentTokenKind() == lexer.COLON {
		Parse.advance()
		returnType = ParseType(Parse, defalt_bp)
	}

	functionBody := ast.ExpectStmt[ast.BlockStmt](ParseBlockStmt(Parse)).Body

	return functionParams, returnType, functionBody
}

func ParseFunctionDeclaration(Parse *Parser) ast.Stmt {
	Parse.advance()
	functionName := Parse.expect(lexer.IDENTIFIER).Literal
	functionParams, returnType, functionBody := ParseFunctionParamsAndBody(Parse)

	return ast.FunctionDeclarationStmt{
		Parameters: functionParams,
		ReturnType: returnType,
		Body:       functionBody,
		Name:       functionName,
	}
}

func ParseIfStmt(Parse *Parser) ast.Stmt {
	Parse.advance()
	condition := ParseExpr(Parse, assignment)
	consequent := ParseBlockStmt(Parse)

	var alternate ast.Stmt
	if Parse.currentTokenKind() == lexer.KEYWORDS_ELSE {
		Parse.advance()

		if Parse.currentTokenKind() == lexer.KEYWORDS_IF {
			alternate = ParseIfStmt(Parse)
		} else {
			alternate = ParseBlockStmt(Parse)
		}
	}

	return ast.IfStmt{
		Condition:  condition,
		Consequent: consequent,
		Alternate:  alternate,
	}
}

func ParseImportStmt(Parse *Parser) ast.Stmt {
	Parse.advance()
	var importFrom string
	importName := Parse.expect(lexer.IDENTIFIER).Literal

	if Parse.currentTokenKind() == lexer.KEYWORDS_IMPORT {
		Parse.advance()
		importFrom = Parse.expect(lexer.TYPE_STRING).Literal
	} else {
		importFrom = importName
	}

	Parse.expect(lexer.SEMI_COLON)
	return ast.ImportStmt{
		Name: importName,
		From: importFrom,
	}
}

func ParseClassDeclStmt(Parse *Parser) ast.Stmt {
	Parse.advance()
	className := Parse.expect(lexer.IDENTIFIER).Literal
	classBody := ParseBlockStmt(Parse)

	return ast.ClassDeclarationStmt{
		Name: className,
		Body: ast.ExpectStmt[ast.BlockStmt](classBody).Body,
	}
}

func ParseReturnStmt(Parse *Parser) ast.Stmt {
	Parse.advance()

	ReturnValue := ParseExpr(Parse, defalt_bp)
	Parse.expect(lexer.SEMI_COLON)

	return ast.ReturnStmt{
		Value: ReturnValue,
	}
}

func ParseForStmt(Parse *Parser) ast.Stmt {
	Parse.advance()

	var init ast.Expr
	var condition ast.Expr
	var post ast.Expr
	var body []ast.Stmt

	if Parse.currentTokenKind() == lexer.OPEN_PAREN {
		Parse.expect(lexer.OPEN_PAREN)

		if Parse.currentTokenKind() != lexer.SEMI_COLON && Parse.currentTokenKind() != lexer.CLOSE_PAREN {
			init = ParseExpr(Parse, defalt_bp)
		}
		Parse.expect(lexer.SEMI_COLON)

		if Parse.currentTokenKind() != lexer.SEMI_COLON && Parse.currentTokenKind() != lexer.CLOSE_PAREN {
			condition = ParseExpr(Parse, defalt_bp)
		} else {
			condition = ast.BooleanExpr{IsTrue: true}
		}
		Parse.expect(lexer.SEMI_COLON)

		if Parse.currentTokenKind() != lexer.CLOSE_PAREN {
			post = ParseExpr(Parse, defalt_bp)
		}
		Parse.expect(lexer.CLOSE_PAREN)
	} else {
		condition = ast.BooleanExpr{IsTrue: true}
	}

	if Parse.currentTokenKind() == lexer.OPEN_BRACE {
		body = ast.ExpectStmt[ast.BlockStmt](ParseBlockStmt(Parse)).Body
	} else {
		body = []ast.Stmt{ParseStmt(Parse)}
	}

	return ast.ForStmt{
		Init:      init,
		Condition: condition,
		Post:      post,
		Body:      body,
	}
}
