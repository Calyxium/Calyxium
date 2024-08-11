package parser

import (
	"fmt"

	"calyxium/ast"
	"calyxium/lexer"
)

type TypeNudHandler func(Parse *Parser) ast.Type
type TypeLedHandler func(Parse *Parser, left ast.Type, bp binding_power) ast.Type

type TypeNudLookup map[lexer.TokenType]TypeNudHandler
type TypeLedLookup map[lexer.TokenType]TypeLedHandler
type TypeBindingPowerLookup map[lexer.TokenType]binding_power

var TypeBindingPowerLu = TypeBindingPowerLookup{}
var TypeNudLu = TypeNudLookup{}
var TypeLedLu = TypeLedLookup{}

func TypeLed(kind lexer.TokenType, bp binding_power, led_fn TypeLedHandler) {
	TypeBindingPowerLu[kind] = bp
	TypeLedLu[kind] = led_fn
}

func TypeNud(kind lexer.TokenType, bp binding_power, nud_fn TypeNudHandler) {
	TypeBindingPowerLu[kind] = primary
	TypeNudLu[kind] = nud_fn
}

func TypePrimary(Parse *Parser) ast.Type {
	return ast.SymbolType{
		Value: Parse.advance().Literal,
	}
}

func CreateTypeTokenLookup() {
	TypeNud(lexer.IDENTIFIER, primary, TypePrimary)
	TypeNud(lexer.TYPE_BOOLEAN, primary, TypePrimary)
	TypeNud(lexer.TYPE_INT, primary, TypePrimary)
	TypeNud(lexer.TYPE_STRING, primary, TypePrimary)
	TypeNud(lexer.TYPE_FLOAT, primary, TypePrimary)
	TypeNud(lexer.TYPE_ANY, primary, TypePrimary)

	TypeNud(lexer.OPEN_BRACKET, member, func(Parse *Parser) ast.Type {
		Parse.advance()
		Parse.expect(lexer.CLOSE_BRACKET)
		insideType := ParseType(Parse, defalt_bp)

		return ast.ListType{
			Underlying: insideType,
		}
	})
}

func ParseType(Parse *Parser, bp binding_power) ast.Type {
	TokenType := Parse.currentTokenKind()
	nud_fn, exists := TypeNudLu[TokenType]

	if !exists {
		fmt.Print(fmt.Errorf("type: NUD Handler expected for token %s", lexer.TokenTypeToString(TokenType)))
	}

	left := nud_fn(Parse)

	for TypeBindingPowerLu[Parse.currentTokenKind()] > bp {
		TokenType = Parse.currentTokenKind()
		led_fn, exists := TypeLedLu[TokenType]

		if !exists {
			fmt.Print(fmt.Errorf("type: LED Handler expected for token %s", lexer.TokenTypeToString(TokenType)))
		}

		left = led_fn(Parse, left, bp)
	}

	return left
}
