package parser

import (
	"fmt"

	"plutonium/lexer"
)

func (Parse *Parser) currentToken() lexer.Token {
	return Parse.tokens[Parse.pos]
}

func (Parse *Parser) advance() lexer.Token {
	tk := Parse.currentToken()
	Parse.pos++
	return tk
}

func (Parse *Parser) hasTokens() bool {
	return Parse.pos < len(Parse.tokens) && Parse.currentTokenKind() != lexer.EOF
}

func (Parse *Parser) currentTokenKind() lexer.TokenType {
	return Parse.tokens[Parse.pos].Type
}

func (Parse *Parser) expectError(expectedKind lexer.TokenType, err any) lexer.Token {
	token := Parse.currentToken()
	kind := token.Type

	if kind != expectedKind {
		if err == nil {
			err = fmt.Errorf("expected %s but recieved %s instead", lexer.TokenTypeToString(expectedKind), lexer.TokenTypeToString(kind))
		}

		fmt.Print(err)
	}

	return Parse.advance()
}

func (Parse *Parser) expect(expectedKind lexer.TokenType) lexer.Token {
	return Parse.expectError(expectedKind, nil)
}
