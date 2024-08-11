package repl

import (
	"bufio"
	"calyxium/checker"
	"calyxium/lexer"
	"calyxium/parser"
	"fmt"
	"io"
	"runtime"
	"time"

	"github.com/sanity-io/litter"
)

var (
	version = "0.0.1"
)

func GetCurrentTime() string {
	now := time.Now()
	format := "Jan 2 2006, 15:04:05"
	return now.Format(format)
}

func GetCurrentPlatform() string {
	return runtime.GOOS
}

func PrintVersion(out io.Writer) {
	fmt.Fprintf(out, "Plutonium %v (%v) on %v\n", version, GetCurrentTime(), GetCurrentPlatform())
}

func Copyright(out io.Writer) {
	fmt.Fprint(out, "Copyright (c) 2024-2024 Plutonium Foundation.\nAll Rights Reserved.\n")
}

func Help(out io.Writer) {
	fmt.Fprint(out, "Type \"help\", \"copyright\", \"credits\" or \"license\"\n")
}

func Repl(in io.Reader, out io.Writer) {
	PrintVersion(out)
	Help(out)

	scanner := bufio.NewScanner(in)

	for {
		fmt.Fprint(out, ">> ")
		if !scanner.Scan() {
			if err := scanner.Err(); err != nil {
				fmt.Fprintf(out, "Error reading input: %v\n", err)
			} else {
				fmt.Fprintln(out, "\nExiting REPL.")
			}
			return
		}

		line := scanner.Text()

		switch line {
		case "exit()":
			fmt.Fprintln(out, "Exiting REPL.")
			return
		case "copyright":
			Copyright(out)
			continue
		case "help":
			Help(out)
			continue
		case "credits":
			fmt.Fprintln(out, "Credits: Plutonium Team")
			continue
		case "license":
			fmt.Fprintln(out, "License: GNUv2 License")
			continue
		}

		tokens, err := tokenize(line)
		if err != nil {
			fmt.Fprintf(out, "Error tokenizing input: %v\n", err)
			continue
		}

		typeCheck(tokens)
		parse(tokens)
		printTokens(out, tokens)
	}
}

func typeCheck(tokens []lexer.Token) {
	ast := parser.Parse(tokens)
	typeChecker := checker.NewTypeChecker()
	if err := typeChecker.Check(ast); err != nil {
		fmt.Println("Type checking failed:", err)
		return
	}
}

func parse(tokens []lexer.Token) {
	ast := parser.Parse(tokens)
	litter.Dump(ast)
}

func tokenize(input string) ([]lexer.Token, error) {
	l := lexer.New(input)
	var tokens []lexer.Token

	for {
		tok := l.Consume()
		if tok.Type == lexer.EOF {
			break
		}
		tokens = append(tokens, tok)
	}

	return tokens, nil
}

func printTokens(out io.Writer, tokens []lexer.Token) {
	for _, tok := range tokens {
		fmt.Fprintf(out, "{Token Type: %v, Value: %v}\n", tok.Type, tok.Literal)
	}
}
