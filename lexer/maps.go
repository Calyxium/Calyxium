package lexer

import "fmt"

var (
	operatorMap = map[byte]TokenType{
		'=': ASSIGN,
		'!': NOT,
		'+': PLUS,
		'-': MINUS,
		'*': MULTIPLY,
		'/': DIVIDE,
		'<': LT,
		'>': GT,
		'|': PIPE,
		'(': OPEN_PAREN,
		')': CLOSE_PAREN,
		'[': OPEN_BRACKET,
		']': CLOSE_BRACKET,
		'{': OPEN_BRACE,
		'}': CLOSE_BRACE,
		'.': DOT,
		'?': QUESTION,
		':': COLON,
		';': SEMI_COLON,
		',': COMMA,
		'"': TYPE_STRING,
	}

	assignmentMap = map[byte]TokenType{
		'=': EQUALS,
		'+': PLUS_ASSIGN,
		'-': MINUS_ASSIGN,
		'*': MULTIPLY_ASSIGN,
		'/': DIVIDE_ASSIGN,
		'<': LESS_THAN_EQUALS,
		'>': GREATER_THAN_EQUALS,
		'|': LOGICAL_OR,
	}

	keywordMap = map[string]TokenType{
		"int":      TYPE_INT,
		"float":    TYPE_FLOAT,
		"bool":     TYPE_BOOLEAN,
		"string":   TYPE_STRING,
		"try":      KEYWORDS_TRY,
		"catch":    KEYWORDS_CATCH,
		"import":   KEYWORDS_IMPORT,
		"true":     KEYWORDS_TRUE,
		"false":    KEYWORDS_FALSE,
		"function": KEYWORDS_FUNCTION,
		"if":       KEYWORDS_IF,
		"let":      KEYWORDS_VAR,
		"const":    KEYWORDS_CONST,
		"else":     KEYWORDS_ELSE,
		"return":   KEYWORDS_RETURN,
		"for":      KEYWORDS_FOR,
		"switch":   KEYWORDS_SWITCH,
		"case":     KEYWORDS_CASE,
		"default":  KEYWORDS_DEFAULT,
	}

	tokenTypeNames = map[TokenType]string{
		EOF:                 "EOF",
		ERROR:               "ERROR",
		MINUS:               "MINUS",
		PLUS:                "PLUS",
		MULTIPLY:            "MULTIPLY",
		DIVIDE:              "DIVIDE",
		OPEN_PAREN:          "OPEN_PAREN",
		CLOSE_PAREN:         "CLOSE_PAREN",
		OPEN_BRACKET:        "OPEN_BRACKET",
		CLOSE_BRACKET:       "CLOSE_BRACKET",
		OPEN_BRACE:          "OPEN_BRACE",
		CLOSE_BRACE:         "CLOSE_BRACE",
		DOT:                 "DOT",
		QUESTION:            "QUESTION",
		COLON:               "COLON",
		SEMI_COLON:          "SEMI_COLON",
		COMMA:               "COMMA",
		NOT:                 "NOT",
		PIPE:                "PIPE",
		TILDE:               "TILDE",
		AMSPERSAND:          "AMSPERSAND",
		GT:                  "GT",
		LT:                  "LT",
		LOGICAL_OR:          "LOGICAL_OR",
		LOGICAL_AND:         "LOGICAL_AND",
		EQUALS:              "EQUALS",
		NOT_EQUALS:          "NOT_EQUALS",
		LESS_THAN_EQUALS:    "LESS_THAN_EQUALS",
		GREATER_THAN_EQUALS: "GREATER_THAN_EQUALS",
		ASSIGN:              "ASSIGN",
		PLUS_ASSIGN:         "PLUS_ASSIGN",
		MINUS_ASSIGN:        "MINUS_ASSIGN",
		MULTIPLY_ASSIGN:     "MULTIPLY_ASSIGN",
		DIVIDE_ASSIGN:       "DIVIDE_ASSIGN",
		IDENTIFIER:          "IDENTIFIER",
		TYPE_STRING:         "TYPE_STRING",
		TYPE_INT:            "TYPE_INT",
		TYPE_FLOAT:          "TYPE_FLOAT",
		TYPE_BOOLEAN:        "TYPE_BOOLEAN",
		KEYWORDS_FUNCTION:   "KEYWORDS_FUNCTION",
		KEYWORDS_IF:         "KEYWORDS_IF",
		KEYWORDS_ELSE:       "KEYWORDS_ELSE",
		KEYWORDS_RETURN:     "KEYWORDS_RETURN",
		KEYWORDS_VAR:        "KEYWORDS_VAR",
		KEYWORDS_CONST:      "KEYWORDS_CONST",
		KEYWORDS_SWITCH:     "KEYWORDS_SWITCH",
		KEYWORDS_FOR:        "KEYWORDS_FOR",
		KEYWORDS_CASE:       "KEYWORDS_CASE",
		KEYWORDS_DEFAULT:    "KEYWORDS_DEFAULT",
		KEYWORDS_TRUE:       "KEYWORDS_TRUE",
		KEYWORDS_FALSE:      "KEYWORDS_FALSE",
		KEYWORDS_TRY:        "KEYWORDS_TRY",
		KEYWORDS_CATCH:      "KEYWORDS_CATCH",
		KEYWORDS_IMPORT:     "KEYWORDS_IMPORT",
	}
)

func TokenTypeToString(t TokenType) string {
	if name, exists := tokenTypeNames[t]; exists {
		return name
	}
	return fmt.Sprintf("UNKNOWN(%d)", t)
}

func ToKeywords(value string) TokenType {
	if tokenType, exists := keywordMap[value]; exists {
		return tokenType
	}
	return IDENTIFIER
}

func GetOperatorType(char byte) TokenType {
	if tokenType, exists := operatorMap[char]; exists {
		return tokenType
	}
	return ERROR
}

func GetAssignmentType(char byte) TokenType {
	if tokenType, exists := assignmentMap[char]; exists {
		return tokenType
	}
	return ERROR
}
