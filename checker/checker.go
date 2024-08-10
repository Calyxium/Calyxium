package checker

import (
	"fmt"
	"plutonium/ast"
)

type TypeChecker struct {
	symbolTable        map[string]ast.Type
	expectedReturnType ast.Type
	importedModules    map[string]bool
	knownModules       map[string]bool
	currentClass       *ast.ClassDeclarationStmt
}

func TypeToString(tp ast.Type) string {
	switch t := tp.(type) {
	case ast.SymbolType:
		return t.Value
	default:
		return "unknown"
	}
}

func NewTypeChecker() *TypeChecker {
	return &TypeChecker{
		symbolTable:     make(map[string]ast.Type),
		importedModules: make(map[string]bool),
		knownModules: map[string]bool{
			"math":    true,
			"strings": true,
			"json":    true,
		},
	}
}

func (tc *TypeChecker) Check(stmtOrBlock interface{}) error {
	switch stmt := stmtOrBlock.(type) {
	case ast.BlockStmt:
		for _, stmt := range stmt.Body {
			if err := tc.checkStmt(stmt); err != nil {
				return err
			}
		}
	case ast.Stmt:
		return tc.checkStmt(stmt)
	default:
		return fmt.Errorf("unsupported type: %T", stmtOrBlock)
	}
	return nil
}

func (tc *TypeChecker) checkStmt(stmt ast.Stmt) error {
	switch s := stmt.(type) {
	case ast.VarDeclarationStmt:
		return tc.checkVarDeclaration(s)
	case ast.ExpressionStmt:
		_, err := tc.checkExpr(s.Expression)
		return err
	case ast.FunctionDeclarationStmt:
		return tc.checkFunctionDeclaration(s)
	case ast.ClassDeclarationStmt:
		return tc.checkClassDeclaration(s)
	case ast.ReturnStmt:
		return tc.checkReturnStmt(s)
	case ast.ImportStmt:
		return tc.checkImportStmt(s)
	case ast.IfStmt:
		return tc.checkIfStmt(s)
	default:
		return fmt.Errorf("unsupported statement type: %T", s)
	}
}

func (tc *TypeChecker) checkExpr(expr ast.Expr) (ast.Type, error) {
	switch e := expr.(type) {
	case ast.IntExpr:
		return ast.SymbolType{Value: "int"}, nil
	case ast.FloatExpr:
		return ast.SymbolType{Value: "float"}, nil
	case ast.StringExpr:
		return ast.SymbolType{Value: "string"}, nil
	case ast.BooleanExpr:
		return ast.SymbolType{Value: "bool"}, nil
	case ast.BinaryExpr:
		return tc.checkBinaryExpr(e)
	case ast.AssignmentExpr:
		return tc.checkAssignmentExpr(e)
	case ast.MemberExpr:
		return tc.checkMemberExpr(e)
	case ast.SymbolExpr:
		return tc.checkSymbolExpr(e)
	default:
		return nil, fmt.Errorf("unsupported expression type: %T", e)
	}
}

func (tc *TypeChecker) checkSymbolExpr(expr ast.SymbolExpr) (ast.Type, error) {
	if symbolType, exists := tc.symbolTable[expr.Value]; exists {
		return symbolType, nil
	}

	return nil, fmt.Errorf("type error: symbol %s not found", expr.Value)
}

func (tc *TypeChecker) checkVarDeclaration(stmt ast.VarDeclarationStmt) error {
	varType, err := tc.checkExpr(stmt.AssignedValue)
	if err != nil {
		return err
	}

	if explicitSymbolType, ok := stmt.ExplicitType.(ast.SymbolType); ok {
		if explicitSymbolType.Value != "" && explicitSymbolType.Value != varType.(ast.SymbolType).Value {
			return fmt.Errorf("type error: variable %s is of type %s but assigned value is of type %s",
				stmt.Identifier, explicitSymbolType.Value, varType.(ast.SymbolType).Value)
		}
	} else {
		return fmt.Errorf("unexpected type for variable %s: %T", stmt.Identifier, stmt.ExplicitType)
	}

	tc.symbolTable[stmt.Identifier] = varType
	return nil
}

func (tc *TypeChecker) checkAssignmentExpr(expr ast.AssignmentExpr) (ast.Type, error) {
	assigneeType, err := tc.checkExpr(expr.Assigne)
	if err != nil {
		return nil, err
	}

	valueType, err := tc.checkExpr(expr.AssignedValue)
	if err != nil {
		return nil, err
	}

	if assigneeType != valueType {
		return nil, fmt.Errorf("type error: cannot assign %s to %s",
			valueType.(ast.SymbolType).Value, assigneeType.(ast.SymbolType).Value)
	}

	return assigneeType, nil
}

func (tc *TypeChecker) checkBinaryExpr(expr ast.BinaryExpr) (ast.Type, error) {
	leftType, err := tc.checkExpr(expr.Left)
	if err != nil {
		return nil, err
	}

	rightType, err := tc.checkExpr(expr.Right)
	if err != nil {
		return nil, err
	}

	if leftType != rightType {
		return nil, fmt.Errorf("type error: binary operation between %s and %s is not allowed",
			leftType.(ast.SymbolType).Value, rightType.(ast.SymbolType).Value)
	}

	switch expr.Operator.Literal {
	case "==", "!=", "<", ">", "<=", ">=":
		return ast.SymbolType{Value: "bool"}, nil
	default:
		return leftType, nil
	}
}

func (tc *TypeChecker) checkFunctionDeclaration(stmt ast.FunctionDeclarationStmt) error {
	originalSymbolTable := tc.symbolTable
	originalReturnType := tc.expectedReturnType

	tc.symbolTable = make(map[string]ast.Type)
	tc.expectedReturnType = stmt.ReturnType

	for _, param := range stmt.Parameters {
		tc.symbolTable[param.Name] = param.Type
	}

	for _, bodyStmt := range stmt.Body {
		if err := tc.checkStmt(bodyStmt); err != nil {
			return err
		}
	}

	tc.symbolTable = originalSymbolTable
	tc.expectedReturnType = originalReturnType

	return nil
}

func (tc *TypeChecker) checkClassDeclaration(stmt ast.ClassDeclarationStmt) error {
	originalSymbolTable := tc.symbolTable
	tc.symbolTable = make(map[string]ast.Type)
	tc.currentClass = &stmt

	for _, bodyStmt := range stmt.Body {
		if err := tc.checkStmt(bodyStmt); err != nil {
			return err
		}
	}

	tc.symbolTable = originalSymbolTable
	tc.currentClass = nil

	return nil
}

func (tc *TypeChecker) checkIfStmt(stmt ast.IfStmt) error {
	ifType, err := tc.checkExpr(stmt.Condition)
	if err != nil {
		return err
	}

	if TypeToString(ifType) != "bool" {
		return fmt.Errorf("type error: if condition type does not match bool")
	}

	tc.checkStmt(stmt.Consequent)

	if tc.checkStmt(stmt.Alternate) != nil {
		tc.checkStmt(stmt.Alternate)
	}

	return nil
}

func (tc *TypeChecker) checkMemberExpr(expr ast.MemberExpr) (ast.Type, error) {
	if symbol, ok := expr.Member.(ast.SymbolExpr); ok && symbol.Value == "this" {
		if tc.currentClass == nil {
			return nil, fmt.Errorf("type error: 'this' used outside of class context")
		}

		for _, bodyStmt := range tc.currentClass.Body {
			if varDecl, ok := bodyStmt.(ast.VarDeclarationStmt); ok && varDecl.Identifier == expr.Property {
				return tc.checkExpr(varDecl.AssignedValue)
			}
		}

		return nil, fmt.Errorf("property %s does not exist on type %s", expr.Property, tc.currentClass.Name)
	}

	objectType, err := tc.checkExpr(expr.Member)
	if err != nil {
		return nil, err
	}

	structType, ok := objectType.(ast.StructType)
	if !ok {
		return nil, fmt.Errorf("type error: %s is not a struct or does not have members", TypeToString(objectType))
	}

	propertyType, exists := structType.GetMemberType(expr.Property)
	if !exists {
		return nil, fmt.Errorf("property %s does not exist on type %s", expr.Property, TypeToString(objectType))
	}

	return propertyType, nil
}

func (tc *TypeChecker) checkReturnStmt(stmt ast.ReturnStmt) error {
	returnType, err := tc.checkExpr(stmt.Value)
	if err != nil {
		return err
	}

	if returnType != tc.expectedReturnType {
		return fmt.Errorf("type error: return type %s does not match expected type %s",
			returnType.(ast.SymbolType).Value, tc.expectedReturnType.(ast.SymbolType).Value)
	}

	return nil
}

func (tc *TypeChecker) checkImportStmt(stmt ast.ImportStmt) error {
	if tc.importedModules[stmt.Name] {
		return fmt.Errorf("module %s is already imported", stmt.Name)
	}

	if !tc.moduleExists(stmt.Name) {
		return fmt.Errorf("module %s does not exist", stmt.Name)
	}

	tc.importedModules[stmt.Name] = true
	return nil
}

func (tc *TypeChecker) moduleExists(moduleName string) bool {
	return tc.knownModules[moduleName]
}
