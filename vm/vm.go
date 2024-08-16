package vm

import (
	"fmt"
	"log"
)

const (
	Push byte = iota
	Dup
	Add
	Sub
	Mul
	Div
	Mod
	Power
	Print
)

type Object struct {
	value    int
	refCount int
}

type VM struct {
	stack    []*Object
	pc       int
	code     []byte
	heap     []*Object
	handlers map[byte]func(*VM)
}

func (vm *VM) allocate(value int) *Object {
	obj := &Object{value: value, refCount: 1}
	vm.heap = append(vm.heap, obj)
	fmt.Printf("Allocated object with value %v (refCount: %v)\n", value, obj.refCount)
	return obj
}

func (vm *VM) pushResult(value int) {
	obj := vm.allocate(value)
	vm.stack = append(vm.stack, obj)
	fmt.Printf("Pushed value %v onto the stack\n", value)
}

func (vm *VM) peek() *Object {
	if len(vm.stack) == 0 {
		log.Fatal("Error: Stack underflow")
	}
	obj := vm.stack[len(vm.stack)-1]
	fmt.Printf("Peeked at top value: %v\n", obj.value)
	return obj
}

func (vm *VM) pop() *Object {
	if len(vm.stack) == 0 {
		log.Fatal("Error: Stack underflow")
	}
	obj := vm.stack[len(vm.stack)-1]
	vm.stack = vm.stack[:len(vm.stack)-1]
	fmt.Printf("Popped value %v from the stack\n", obj.value)
	if obj.refCount--; obj.refCount == 0 {
		vm.collect(obj)
	}
	return obj
}

func (vm *VM) collect(obj *Object) {
	for i, o := range vm.heap {
		if o == obj {
			fmt.Printf("Collecting object with value %v\n", obj.value)
			vm.heap = append(vm.heap[:i], vm.heap[i+1:]...)
			break
		}
	}
}
