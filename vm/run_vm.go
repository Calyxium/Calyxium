package vm

import (
	"fmt"
	"os"
)

func (vm *VM) Run() {
	for vm.pc < len(vm.code) {
		instr := vm.code[vm.pc]
		vm.pc++

		switch instr {
		case Push:
			value := int(vm.code[vm.pc])
			vm.pc++
			vm.push(value)
		case Add:
			a := vm.pop()
			b := vm.pop()
			vm.push(a + b)
		case Sub:
			a := vm.pop()
			b := vm.pop()
			vm.push(a - b)
		case Mul:
			a := vm.pop()
			b := vm.pop()
			vm.push(a * b)
		case Div:
			a := vm.pop()
			b := vm.pop()
			vm.push(a / b)
		case Mod:
			a := vm.pop()
			b := vm.pop()
			vm.push(a % b)
		case Print:
			value := vm.pop()
			fmt.Println(value)
		default:
			fmt.Println("Error: Invalid instruction -> ", instr)
			os.Exit(1)
		}
	}
}
