package main

import (
	"fmt"
	"os"
	"strings"

	"plutonium/lexer"
)

func GetInputFilePath() (string, error) {
	if len(os.Args) < 2 {
		return "", fmt.Errorf("%v: fatal error: no input files provided", strings.Join(strings.Split(os.Args[0], "./"), ""))
	}
	return os.Args[1], nil
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
	filePath, err := GetInputFilePath()
	if err != nil {
		fmt.Println(err)
		return
	}

	content, err := ReadFileContent(filePath)
	if err != nil {
		fmt.Println(err)
		return
	}

	newLexer := lexer.New(string(content))

	for {
		tok := newLexer.Consume()
		fmt.Printf("{Token Type: %v, Value: %v}\n", tok.Type, tok.Literal)
		if tok.Type == lexer.EOF {
			break
		}
	}
}
