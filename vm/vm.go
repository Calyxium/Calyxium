package vm

import (
	"fmt"
	"os"
)

const (
	Push  byte = iota // Push a value onto the stack
	Dup               // Duplicate the top value on the stack
	Add               // Pop the top two values off the stack, add them, and push the result
	Sub               // Pop the top two values off the stack, subtract them, and push the result
	Mul               // Pop the top two values off the stack, multiply them, and push the result
	Div               // Pop the top two values off the stack, divide them, and push the result
	Mod               // Pop the top two values off the stack, divide them, and push the remainder
	Power             // Pop the top two values off the stack, raise the first to the power of the second, and push the result
	Print             // Pop the top value off the stack and print it
)

// Object represents an dynamically allocated object
type Object struct {
	value    int
	refCount int // reference count
}

// VM represents a virtual machine
type VM struct {
	stack    []*Object          // Stack holds pointers to objects
	pc       int                // Program counter
	code     []byte             // Bytecode to execute
	handlers map[byte]func(*VM) // Handlers for each opcode
	heap     []*Object          // Heap holds pointers to objects
}

func (vm *VM) allocate(value int) *Object {
	obj := &Object{value: value, refCount: 1}
	vm.heap = append(vm.heap, obj)
	fmt.Printf("Allocated object with value %d (refCount: %d)\n", value, obj.refCount)
	return obj
}

// Increment the reference count of an object
func (vm *VM) retain(obj *Object) {
	obj.refCount++
	fmt.Printf("Retained object with value %d (refCount: %d)\n", obj.value, obj.refCount)
}

// Decrement the reference count of an object and free it if the count reaches zero
func (vm *VM) release(obj *Object) {
	obj.refCount--
	fmt.Printf("Released object with value %d (refCount: %d)\n", obj.value, obj.refCount)
	if obj.refCount == 0 {
		for i, o := range vm.heap {
			if o == obj {
				fmt.Printf("Collecting object with value %d\n", obj.value)
				vm.heap = append(vm.heap[:i], vm.heap[i+1:]...)
				break
			}
		}
	}
}

func (vm *VM) pushResult(value int) {
	obj := vm.allocate(value) // Allocate a new object
	vm.stack = append(vm.stack, obj)
}

// Peek returns the top value on the stack without removing it
func (vm *VM) peek() *Object {
	if len(vm.stack) == 0 {
		fmt.Println("Error: Stack underflow!")
		os.Exit(1)
	}
	return vm.stack[len(vm.stack)-1]
}

// Pop removes the top value from the stack and returns it
func (vm *VM) pop() *Object {
	if len(vm.stack) == 0 {
		fmt.Println("Error: Stack underflow")
		os.Exit(1)
	}
	obj := vm.stack[len(vm.stack)-1]
	vm.stack = vm.stack[:len(vm.stack)-1]
	vm.release(obj)
	return obj
}
