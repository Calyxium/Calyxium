package lexer

type TokenType int

type Token struct {
	Type    TokenType
	Literal string
}

const (
	EOF TokenType = iota

	ERROR    // Err
	MINUS    // -
	PLUS     // +
	MULTIPLY // *
	DIVIDE   // /

	OPEN_PAREN          // (
	CLOSE_PAREN         // )
	OPEN_BRACKET        // [
	CLOSE_BRACKET       // ]
	OPEN_BRACE          // {
	CLOSE_BRACE         // }
	DOT                 // .
	QUESTION            // ?
	COLON               // :
	SEMI_COLON          // ;
	COMMA               // ,
	NOT                 // !
	PIPE                // |
	TILDE               // ~
	AMSPERSAND          // &
	GT                  // >
	LT                  // <
	LOGICAL_OR          // ||
	LOGICAL_AND         // &&
	EQUALS              // ==
	NOT_EQUALS          // !=
	LESS_THAN_EQUALS    // <=
	GREATER_THAN_EQUALS // >=
	ASSIGN              // =
	PLUS_ASSIGN         // +=
	MINUS_ASSIGN        // -=
	MULTIPLY_ASSIGN     // *=
	DIVIDE_ASSIGN       // /=

	IDENTIFIER
	TYPE_STRING  // "Hello"
	TYPE_INT     // 10
	TYPE_FLOAT   // 10.0
	TYPE_BOOLEAN // True or False
	TYPE_ANY     // any

	KEYWORDS_FUNCTION // function
	KEYWORDS_IF       // if
	KEYWORDS_ELSE     // else
	KEYWORDS_RETURN   // return
	KEYWORDS_VAR      // let
	KEYWORDS_CONST    // const
	KEYWORDS_SWITCH   // switch
	KEYWORDS_FOR      // for
	KEYWORDS_CASE     // case
	KEYWORDS_DEFAULT  // default
	KEYWORDS_TRUE     // true
	KEYWORDS_FALSE    // false
	KEYWORDS_TRY      // try
	KEYWORDS_CATCH    // catch
	KEYWORDS_IMPORT   // import
	KEYWORDS_CLASS    // class
	KEYWORDS_THIS     // this

)
