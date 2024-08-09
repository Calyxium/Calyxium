package checker_test

import (
	"plutonium/ast"
	"plutonium/checker"
	"plutonium/lexer"
	"testing"
)

func TestFunctionDeclarationTypeChecking(t *testing.T) {
	typeChecker := checker.NewTypeChecker()

	funcStmt := ast.FunctionDeclarationStmt{
		Name: "add",
		Parameters: []ast.Parameter{
			{Name: "a", Type: ast.SymbolType{Value: "int"}},
			{Name: "b", Type: ast.SymbolType{Value: "int"}},
		},
		Body: []ast.Stmt{
			ast.ReturnStmt{
				Value: ast.BinaryExpr{
					Left:     ast.IntExpr{Value: 10},
					Right:    ast.IntExpr{Value: 10},
					Operator: lexer.Token{Type: lexer.PLUS},
				},
			},
		},
		ReturnType: ast.SymbolType{Value: "int"},
	}

	if err := typeChecker.Check(funcStmt); err != nil {
		t.Errorf("expected no error, but got: %s", err)
	}

	funcStmt.ReturnType = ast.SymbolType{Value: "string"}
	if err := typeChecker.Check(funcStmt); err == nil {
		t.Error("expected a type mismatch error, but got none")
	}
}

func TestClassDeclarationTypeChecking(t *testing.T) {
	typeChecker := checker.NewTypeChecker()

	// Test case: Class with matching method types
	classStmt := ast.ClassDeclarationStmt{
		Name: "Calculator",
		Body: []ast.Stmt{
			ast.FunctionDeclarationStmt{
				Name: "add",
				Parameters: []ast.Parameter{
					{Name: "a", Type: ast.SymbolType{Value: "int"}},
					{Name: "b", Type: ast.SymbolType{Value: "int"}},
				},
				Body: []ast.Stmt{
					ast.ReturnStmt{
						Value: ast.BinaryExpr{
							Left:     ast.IntExpr{Value: 5},
							Right:    ast.IntExpr{Value: 10},
							Operator: lexer.Token{Type: lexer.PLUS},
						},
					},
				},
				ReturnType: ast.SymbolType{Value: "int"},
			},
		},
	}

	if err := typeChecker.Check(classStmt); err != nil {
		t.Errorf("expected no error, but got: %s", err)
	}

	if funcDecl, ok := classStmt.Body[0].(ast.FunctionDeclarationStmt); ok {
		funcDecl.ReturnType = ast.SymbolType{Value: "string"}
		classStmt.Body[0] = funcDecl
	} else {
		t.Error("expected ast.FunctionDeclarationStmt, but got something else")
	}

	if err := typeChecker.Check(classStmt); err == nil {
		t.Error("expected a type mismatch error, but got none")
	}
}
