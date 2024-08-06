package lexer

import (
	"fmt"
	"plutonium/inc"
	"strings"
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

	fmt.Printf(inc.Red+"Error"+inc.Reset+": [line: "+inc.Blue+"%d"+inc.Reset+", column: "+inc.Cyan+"%d"+inc.Reset+"] "+inc.Yellow+"Unexpected character '%c'\n"+inc.Reset, lex.Line, lex.Column, char)

	fmt.Printf(" %d | %s\n", lex.Line, lineContent)
	caretPosition := lex.Column - 1
	if caretPosition < 0 {
		caretPosition = 0
	}
	fmt.Printf("   | %s^\n", strings.Repeat(" ", caretPosition))
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

func (lex *Lexer) ReadString() string {
	startPosition := lex.Position + 1
	for {
		lex.advance()
		if lex.CurrentChar == '"' {
			break
		}
	}
	str := lex.Content[startPosition:lex.Position]
	lex.advance()
	return str
}

func (lex *Lexer) ReadIdentifier() string {
	startPosition := lex.Position
	for IsAlpha(lex.CurrentChar) {
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

func CreateToken(tokenType TokenType, char byte) Token {
	return Token{
		Type:    tokenType,
		Literal: string(char),
	}
}

func (lex *Lexer) Consume() Token {
	lex.SkipWhitespace()

	var tok Token

	if lex.CurrentChar == 0 {
		return Token{Type: EOF, Literal: "EOF"}
	}

	if tokenType := GetOperatorType(lex.CurrentChar); tokenType != ERROR {
		if tokenType == TYPE_STRING {
			tok.Type = TYPE_STRING
			tok.Literal = lex.ReadString()
			return tok
		}
		tok = CreateToken(tokenType, lex.CurrentChar)
		if lex.Peek() == '=' {
			lex.advance()
			tok.Type = GetAssignmentType(lex.CurrentChar)
			tok.Literal = TokenTypeToString(tok.Type)
		}
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
			return tok
		}
		return tok
	default:
		tok = CreateToken(ERROR, lex.CurrentChar)
		ReportError(lex, lex.CurrentChar)
	}

	lex.advance()
	return tok
}
