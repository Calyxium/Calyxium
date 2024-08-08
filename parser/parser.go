package parser

import (
	"plutonium/ast"
	"plutonium/lexer"
)

type Parser struct {
	tokens []lexer.Token
	pos    int
}

func createParser(tokens []lexer.Token) *Parser {
	CreateTokenLookup()
	CreateTypeTokenLookup()

	p := &Parser{
		tokens: tokens,
		pos:    0,
	}

	return p
}

func Parse(tks []lexer.Token) ast.BlockStmt {
	p := createParser(tks)
	body := make([]ast.Stmt, 0)

	for p.hasTokens() {
		body = append(body, ParseStmt(p))
	}

	return ast.BlockStmt{
		Body: body,
	}
}
