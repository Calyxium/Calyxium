package errors

import (
	"fmt"
	"strings"
)

type LexerError struct {
	Line        int
	Column      int
	Char        byte
	LineContent string
	Message     string
}

func NewLexerError(line, column int, char byte, lineContent, message string) *LexerError {
	return &LexerError{
		Line:        line,
		Column:      column,
		Char:        char,
		LineContent: lineContent,
		Message:     message,
	}
}

func (e *LexerError) Error() string {
	caretPosition := e.Column - 1
	if caretPosition < 0 {
		caretPosition = 0
	}
	return fmt.Sprintf(
		"Error: [line: %d, column: %d] %s '%c'\n %d | %s\n   | %s^\n",
		e.Line, e.Column, e.Message, e.Char, e.Line, e.LineContent,
		strings.Repeat(" ", caretPosition),
	)
}
