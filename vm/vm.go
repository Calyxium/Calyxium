package vm

import (
	"fmt"
	"os"
)

const (
	Push  byte = iota // Push a value onto the stack
	Add               // Pop the top two values off the stack, add them, and push the result
	Sub               // Pop the top two values off the stack, subtract them, and push the result
	Mul               // Pop the top two values off the stack, multiply them, and push the result
	Div               // Pop the top two values off the stack, divide them, and push the result
	Mod               // Pop the top two values off the stack, divide them, and push the remainder
	Print             // Pop the top value off the stack and print it
)

type VM struct {
	stack    []int
	pc       int
	code     []byte
	handlers map[byte]func(*VM)
}

func (vm *VM) pushResult(value int) {
	vm.stack = append(vm.stack, value)
}

func (vm *VM) pop() int {
	if len(vm.stack) == 0 {
		fmt.Println("Error: Stack is underflow!")
		os.Exit(1)
	}
	value := vm.stack[len(vm.stack)-1]
	vm.stack = vm.stack[:len(vm.stack)-1]
	return value
}
