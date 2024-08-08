package main

import (
	"fmt"
	"os"
	"plutonium/lexer"
	"plutonium/parser"
	"plutonium/repl"
	"time"

	"github.com/sanity-io/litter"
)

func GetInputFilePath() string {
	if len(os.Args) < 2 {
		return ""
	}
	return os.Args[1]
}

func ReadFileContent(filePath string) (string, error) {
	file, err := os.Open(filePath)
	if err != nil {
		return "", fmt.Errorf("error opening file: %w", err)
	}
	defer file.Close()

	content, err := os.ReadFile(file.Name())
	if err != nil {
		return "", fmt.Errorf("error reading file: %w", err)
	}

	return string(content), nil
}

func main() {
	filePath := GetInputFilePath()

	if filePath == "" {
		repl.Repl(os.Stdin, os.Stdout)
		return
	}

	content, err := ReadFileContent(filePath)
	if err != nil {
		fmt.Println(err)
		return
	}

	newLexer := lexer.New(string(content))
	var tokens []lexer.Token

	for {
		tok := newLexer.Consume()
		if tok.Type == lexer.EOF {
			break
		}
		tokens = append(tokens, tok)
	}

	start := time.Now()
	ast := parser.Parse(tokens)

	duration := time.Since(start)
	litter.Dump(ast)
	fmt.Printf("Duration: %v\n", duration)

}
