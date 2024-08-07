package parser

import (
	"fmt"
	"plutonium/ast"
	"plutonium/lexer"
)

type Parser struct {
	tokens []lexer.Token
	pos    int
}

func New(tokens []lexer.Token) *Parser {
	CreateTokenLookup()
	return &Parser{
		tokens: tokens,
		pos:    0,
	}
}

func Parse(tokens []lexer.Token) ast.BlockStmt {
	Body := make([]ast.Stmt, 0)
	parser := New(tokens)

	for parser.HasToken() {
		Body = append(Body, ParseStmt(parser))
	}

	return ast.BlockStmt{
		Body: Body,
	}
}

func (parse *Parser) CurrentToken() lexer.Token {
	return parse.tokens[parse.pos]
}

func (parse *Parser) CurrentTokenType() lexer.TokenType {
	return parse.CurrentToken().Type
}

func (parse *Parser) advance() lexer.Token {
	token := parse.CurrentToken()
	parse.pos++
	return token
}

func (parse *Parser) HasToken() bool {
	return parse.pos < len(parse.tokens) && parse.CurrentTokenType() != lexer.EOF
}

func (Parse *Parser) ExpectError(ExpectedType lexer.TokenType, err any) lexer.Token {
	token := Parse.CurrentToken()
	Kind := token.Type

	if Kind != ExpectedType {
		if err == nil {
			err = fmt.Sprintf("Expected %v but recieved %v instead\n", lexer.TokenTypeToString(ExpectedType), lexer.TokenTypeToString(Kind))
		}

		panic(err)
	}

	return Parse.advance()
}

func (Parse *Parser) Expect(ExpectedType lexer.TokenType) lexer.Token {
	return Parse.ExpectError(ExpectedType, nil)
}
