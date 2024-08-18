package vm

import (
	"calyxium/ast"
	"fmt"
	"log"
)

func (vm *VM) TraversAst(node ast.BlockStmt) {
	stmtMap := map[string]func(interface{}){
		"ast.ExpressionStmt": vm.handleExpressionStmt,
	}

	for _, stmt := range node.Body {
		stmtType := fmt.Sprintf("%T", stmt)
		if handler, ok := stmtMap[stmtType]; ok {
			handler(stmt)
		} else {
			log.Fatalf("Error: Unknown statement type %s\n", stmtType)
		}
	}

	// run the VM
	vm.Run()
}

func (vm *VM) traverseExpr(expr interface{}) {
	exprMap := map[string]func(interface{}){
		"ast.BinaryExpr": vm.handleBinaryExpr,
		"ast.IntExpr":    vm.handleIntExpr,
	}

	exprType := fmt.Sprintf("%T", expr)
	if handler, ok := exprMap[exprType]; ok {
		handler(expr)
	} else {
		log.Fatalf("Error: Unknown expression type %s\n", exprType)
	}
}

func (vm *VM) handleExpressionStmt(stmt interface{}) {
	exprStmt := stmt.(ast.ExpressionStmt)
	vm.traverseExpr(exprStmt.Expression)
}

func (vm *VM) handleBinaryExpr(expr interface{}) {
	binExpr := expr.(ast.BinaryExpr)
	vm.traverseExpr(binExpr.Left)
	vm.traverseExpr(binExpr.Right)

	binaryOpMap := map[string]byte{
		"+": Add,
		"-": Sub,
		"*": Mul,
		"/": Div,
		"%": Mod,
	}

	if opcode, ok := binaryOpMap[binExpr.Operator.Literal]; ok {
		vm.emitByte(opcode)
	} else {
		log.Fatalf("Error: Unknown binary operator %s\n", binExpr.Operator.Literal)
	}
}

func (vm *VM) handleIntExpr(expr interface{}) {
	intExpr := expr.(ast.IntExpr)
	vm.emitBytes(Push, byte(intExpr.Value))
}
