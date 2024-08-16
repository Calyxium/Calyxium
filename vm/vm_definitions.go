package vm

import (
	"fmt"
)

// NewVM creates a new VM instance with instruction handlers
func NewVM(code []byte) *VM {
	// a map for the instructions that link to a function
	handlers := map[byte]func(*VM){
		Push:  (*VM).push,
		Add:   (*VM).add,
		Sub:   (*VM).sub,
		Mul:   (*VM).mul,
		Div:   (*VM).div,
		Mod:   (*VM).mod,
		Print: (*VM).print,
	}

	return &VM{
		stack:    make([]int, 0),
		pc:       0,
		code:     code,
		handlers: handlers,
	}
}

func (vm *VM) push() {
	vm.pc++ // Increment pc to get the next byte which is the value to push
	value := int(vm.code[vm.pc])
	vm.stack = append(vm.stack, value)
}

func (vm *VM) add() {
	b := vm.pop()
	a := vm.pop()
	vm.pushResult(a + b)
}

func (vm *VM) sub() {
	b := vm.pop()
	a := vm.pop()
	vm.pushResult(a - b)
}

func (vm *VM) mul() {
	b := vm.pop()
	a := vm.pop()
	vm.pushResult(a * b)
}

func (vm *VM) div() {
	b := vm.pop()
	a := vm.pop()
	vm.pushResult(a / b)
}

func (vm *VM) mod() {
	b := vm.pop()
	a := vm.pop()
	vm.pushResult(a % b)
}

func (vm *VM) print() {
	value := vm.pop()
	fmt.Println(value)
}
