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
	var assignedValue ast.Expr
	IsConstant := Parse.advance().Type == lexer.KEYWORDS_CONST
	VarName := Parse.ExpectError(lexer.IDENTIFIER, "Inside variable decleration expected to find variable name").Literal

	if Parse.CurrentTokenType() == lexer.COLON {
		Parse.advance()
		ExplicitType = ParseType(Parse, DEFAULT_BP)
	}

	if Parse.CurrentTokenType() != lexer.SEMI_COLON {
		Parse.Expect(lexer.ASSIGN)
		assignedValue = ParseExpr(Parse, ASSINGMENT)
	} else if ExplicitType == nil {
		panic("Missing either right hand side in variable decleration or explicit type.")
	}

	Parse.Expect(lexer.SEMI_COLON)

	if IsConstant && assignedValue == nil {
		panic("Cannot define constants without providing value")
	}

	return ast.VarDeclStmt{
		ExplicitType:  ExplicitType,
		IsConstant:    IsConstant,
		VariableName:  VarName,
		AssignedValue: assignedValue,
	}
}

func ParseStructDeclStmt(Parse *Parser) ast.Stmt {
	Parse.Expect(lexer.KEYWORDS_STRUCT)
	var Methods = map[string]ast.StructMethod{}
	var Properties = map[string]ast.StructProperty{}
	var StructName = Parse.Expect(lexer.IDENTIFIER).Literal

	Parse.Expect(lexer.OPEN_BRACE)

	for Parse.HasToken() && Parse.CurrentTokenType() != lexer.CLOSE_BRACE {
		var IsStatic bool
		var propertyName string
		if Parse.CurrentTokenType() == lexer.KEYWORDS_STATIC {
			IsStatic = true
			Parse.Expect(lexer.KEYWORDS_STATIC)
		}

		if Parse.CurrentTokenType() == lexer.IDENTIFIER {
			propertyName = Parse.Expect(lexer.IDENTIFIER).Literal
			Parse.ExpectError(lexer.COLON, "Expected to find colon following property name inside struct declaration")
			StructType := ParseType(Parse, DEFAULT_BP)
			Parse.Expect(lexer.SEMI_COLON)

			_, exists := Properties[propertyName]

			if exists {
				panic(fmt.Sprintf("Propery %v has already been defined in struct declaration", propertyName))
			}

			Properties[propertyName] = ast.StructProperty{
				IsStatic: IsStatic,
				Type:     StructType,
			}

			continue
		}

		panic("Cannot currently handle methods inside struct decl")
	}

	Parse.Expect(lexer.CLOSE_BRACE)

	return ast.StructStmt{
		Properties: Properties,
		Methods:    Methods,
		StructName: StructName,
	}
}
