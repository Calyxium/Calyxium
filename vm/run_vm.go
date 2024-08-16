package vm

import (
	"fmt"
	"os"
)

func (vm *VM) Run() {
	for vm.pc < len(vm.code) {
		opcode := vm.code[vm.pc]
		handler, ok := vm.handlers[opcode]
		if !ok {
			fmt.Printf("Error: Unknown opcode %d\n", opcode)
			os.Exit(1)
		}

		handler(vm)
		vm.pc++
	}
}
