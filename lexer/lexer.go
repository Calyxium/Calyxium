package lexer

import (
	"calyxium/errors"
	"fmt"
)

type Lexer struct {
	Content      string
	Position     int
	ReadPosition int
	CurrentChar  byte
	Line         int
	Column       int
}

func New(input string) *Lexer {
	lex := &Lexer{Content: input}
	lex.advance()
	lex.Line = 1
	return lex
}

func (lex *Lexer) LineContent(line int) string {
	start := 0
	currentLine := 1

	for currentLine != line && start < len(lex.Content) {
		if lex.Content[start] == '\n' {
			currentLine++
		}
		start++
	}
	end := start
	for end < len(lex.Content) && lex.Content[end] != '\n' {
		end++
	}
	return lex.Content[start:end]
}

func ReportError(lex *Lexer, char byte) {
	lineContent := lex.LineContent(lex.Line)

	err := errors.NewLexerError(lex.Line, lex.Column, char, lineContent, "Unexpected character")
	fmt.Print(err.Error())
	lex.advance()
}

func IsDigit(char byte) bool {
	return char >= '0' && char <= '9'
}

func IsAlpha(char byte) bool {
	return (char >= 'a' && char <= 'z') || (char >= 'A' && char <= 'Z') || (char == '_' || char == '$')
}

func (lex *Lexer) SkipWhitespace() {
	for lex.CurrentChar == ' ' || lex.CurrentChar == '\t' || lex.CurrentChar == '\n' || lex.CurrentChar == '\r' || lex.CurrentChar == '#' {
		lex.advance()
	}
}

func (lex *Lexer) advance() {
	if lex.ReadPosition >= len(lex.Content) {
		lex.CurrentChar = 0
	} else {
		lex.CurrentChar = lex.Content[lex.ReadPosition]
	}

	if lex.CurrentChar == '\n' {
		lex.Line++
		lex.Column = 0
	} else {
		lex.Column++
	}

	lex.Position = lex.ReadPosition
	lex.ReadPosition++
}

func (lex *Lexer) ReadString() Token {
	startPosition := lex.Position + 1
	lex.advance()

	for lex.CurrentChar != '"' && lex.CurrentChar != 0 {
		lex.advance()
	}

	var literal string
	if lex.CurrentChar == '"' {
		literal = lex.Content[startPosition:lex.Position]
		lex.advance()
	} else {
		ReportError(lex, lex.CurrentChar)
		literal = lex.Content[startPosition:lex.Position]
	}

	return CreateToken(STRING, literal)
}

func (lex *Lexer) ReadIdentifier() string {
	startPosition := lex.Position
	for IsAlpha(lex.CurrentChar) || IsDigit(lex.CurrentChar) {
		lex.advance()
	}
	return lex.Content[startPosition:lex.Position]
}

func (lex *Lexer) ReadNumber() (string, bool) {
	startPosition := lex.Position
	isFloat := false
	for IsDigit(lex.CurrentChar) {
		lex.advance()
	}
	if lex.CurrentChar == '.' {
		lex.advance()
		for IsDigit(lex.CurrentChar) {
			lex.advance()
		}
		isFloat = true
	}
	return lex.Content[startPosition:lex.Position], isFloat
}

func (lex *Lexer) Peek() byte {
	if lex.ReadPosition >= len(lex.Content) {
		return 0
	}
	return lex.Content[lex.ReadPosition]
}

func CreateToken(tokenType TokenType, lit string) Token {
	return Token{
		Type:    tokenType,
		Literal: lit,
	}
}

func (lex *Lexer) Consume() Token {
	lex.SkipWhitespace()

	var tok Token

	if lex.CurrentChar == 0 {
		return Token{Type: EOF, Literal: "EOF"}
	}

	if lex.CurrentChar == '"' {
		return lex.ReadString()
	}

	if tokenType := GetAssignmentType(string(lex.CurrentChar) + string(lex.Peek())); tokenType != ERROR {
		tok = CreateToken(tokenType, string(lex.CurrentChar)+string(lex.Peek()))
		lex.advance()
		lex.advance()
		return tok
	}

	if tokenType := GetOperatorType(lex.CurrentChar); tokenType != ERROR {
		tok = CreateToken(tokenType, string(lex.CurrentChar))
		lex.advance()
		return tok
	}

	switch {
	case IsAlpha(lex.CurrentChar):
		tok.Literal = lex.ReadIdentifier()
		tok.Type = ToKeywords(tok.Literal)
		return tok
	case IsDigit(lex.CurrentChar):
		literal, isFloat := lex.ReadNumber()
		tok.Literal = literal
		tok.Type = TYPE_INT
		if isFloat {
			tok.Type = TYPE_FLOAT
		}
		return tok
	default:
		tok = CreateToken(ERROR, "ERROR")
		ReportError(lex, lex.CurrentChar)
	}

	lex.advance()
	return tok
}
