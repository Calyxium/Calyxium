package vm

import (
	"fmt"
)

// NewVM creates a new VM instance with instruction handlers
func NewVM(code []byte) *VM {
	// a map for the instructions that link to a function
	handlers := map[byte]func(*VM){
		Push:  (*VM).push,
		Dup:   (*VM).dup,
		Add:   (*VM).add,
		Sub:   (*VM).sub,
		Mul:   (*VM).mul,
		Div:   (*VM).div,
		Mod:   (*VM).mod,
		Power: (*VM).power,
		Print: (*VM).print,
	}

	return &VM{
		stack:    make([]*Object, 0),
		pc:       0,
		code:     code,
		handlers: handlers,
		heap:     make([]*Object, 0),
	}
}

func (vm *VM) push() {
	vm.pc++ // Increment pc to get the next byte which is the value to push
	value := int(vm.code[vm.pc])
	obj := vm.allocate(value)
	vm.stack = append(vm.stack, obj)
}

func (vm *VM) dup() {
	obj := vm.peek()
	vm.retain(obj)
	vm.stack = append(vm.stack, obj)
}

func (vm *VM) add() {
	b := vm.pop()
	a := vm.pop()
	vm.pushResult(a.value + b.value)
}

func (vm *VM) sub() {
	b := vm.pop()
	a := vm.pop()
	vm.pushResult(a.value - b.value)
}

func (vm *VM) mul() {
	b := vm.pop()
	a := vm.pop()
	vm.pushResult(a.value * b.value)
}

func (vm *VM) div() {
	b := vm.pop()
	a := vm.pop()
	vm.pushResult(a.value / b.value)
}

func (vm *VM) mod() {
	b := vm.pop()
	a := vm.pop()
	vm.pushResult(a.value % b.value)
}

func (vm *VM) power() {
	b := vm.pop()
	a := vm.pop()
	result := 1
	for i := 0; i < b.value; i++ {
		result *= a.value
	}
	vm.pushResult(result)
}

func (vm *VM) print() {
	obj := vm.peek()
	fmt.Println(obj.value)
}
