package parser

import (
	"fmt"
	"plutonium/ast"
	"plutonium/lexer"
)

type TypeNudHandler func(Parse *Parser) ast.Type
type TypeLedHanlder func(Parse *Parser, Left ast.Type, Bp BindingPower) ast.Type

type TypeNudLookup map[lexer.TokenType]TypeNudHandler
type TypeLedLookup map[lexer.TokenType]TypeLedHanlder
type TypeBindingPowerLookup map[lexer.TokenType]BindingPower

var (
	TypeBindingPowerLu = BindingPowerLookup{}
	TypeNudLu          = TypeNudLookup{}
	TypeLedLu          = TypeLedLookup{}
)

func TypeLed(Type lexer.TokenType, BindingPower BindingPower, LedFunction TypeLedHanlder) {
	TypeBindingPowerLu[Type] = BindingPower
	TypeLedLu[Type] = LedFunction
}

func TypeNud(Type lexer.TokenType, BindingPower BindingPower, NudFunction TypeNudHandler) {
	TypeBindingPowerLu[Type] = PRIMARY
	TypeNudLu[Type] = NudFunction
}

func CreateTokenTypeLookup() {
	TypeNud(lexer.IDENTIFIER, PRIMARY, func(Parse *Parser) ast.Type {
		return ast.SymbolType{
			Name: Parse.advance().Literal,
		}
	})

	TypeNud(lexer.OPEN_BRACKET, MEMBER, func(Parse *Parser) ast.Type {
		Parse.advance()
		Parse.Expect(lexer.CLOSE_BRACKET)
		InsideType := ParseType(Parse, DEFAULT_BP)

		return ast.ArrayType{
			Underlying: InsideType,
		}
	})
}

func ParseSymbolType(Parse *Parser) ast.Type {
	return ast.SymbolType{
		Name: Parse.Expect(lexer.IDENTIFIER).Literal,
	}
}

func ParseArrayType(Parse *Parser) ast.Type {
	Parse.advance()
	Parse.Expect(lexer.CLOSE_BRACKET)
	var UnderlyingType = ParseType(Parse, DEFAULT_BP)
	return ast.ArrayType{
		Underlying: UnderlyingType,
	}
}

func ParseType(Parse *Parser, BindingPower BindingPower) ast.Type {
	TokenType := Parse.CurrentTokenType()
	NudFunction, exists := TypeNudLu[TokenType]

	if !exists {
		panic(fmt.Sprintf("Type Nud handler expected for token %v\n", lexer.TokenTypeToString(TokenType)))
	}

	Left := NudFunction(Parse)

	for TypeBindingPowerLu[Parse.CurrentTokenType()] > BindingPower {
		TokenType = Parse.CurrentTokenType()
		LedFunction, exists := TypeLedLu[TokenType]

		if !exists {
			panic(fmt.Sprintf("Type Led handler expected for token %v\n", lexer.TokenTypeToString(TokenType)))
		}

		Left = LedFunction(Parse, Left, BindingPowerLu[Parse.CurrentTokenType()])
	}

	return Left
}
