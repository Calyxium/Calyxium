package vm

import "fmt"

// NewVM creates a new VM instance with instruction handlers
func NewVM() *VM {
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
		stack:    []*Object{},
		code:     []byte{},
		handlers: handlers,
		heap:     []*Object{},
		line:     1,
		pos:      0,
	}
}

func (vm *VM) push() {
	vm.pc++
	vm.pushResult(int(vm.code[vm.pc]))
}

func (vm *VM) dup() {
	obj := vm.peek()
	vm.stack = append(vm.stack, obj)
	obj.refCount++
}

func (vm *VM) add() {
	b, a := vm.pop(), vm.pop()
	vm.pushResult(a.value + b.value)
}

func (vm *VM) sub() {
	b, a := vm.pop(), vm.pop()
	vm.pushResult(a.value - b.value)
}

func (vm *VM) mul() {
	b, a := vm.pop(), vm.pop()
	vm.pushResult(a.value * b.value)
}

func (vm *VM) div() {
	b, a := vm.pop(), vm.pop()
	vm.pushResult(a.value / b.value)
}

func (vm *VM) mod() {
	b, a := vm.pop(), vm.pop()
	vm.pushResult(a.value % b.value)
}

func (vm *VM) power() {
	b, a := vm.pop(), vm.pop()
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
