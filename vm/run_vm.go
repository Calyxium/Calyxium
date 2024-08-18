package vm

import "log"

// Run executes the bytecode in the VM
func (vm *VM) Run() {
	for vm.pc < len(vm.code) {
		opcode := vm.code[vm.pc]
		if handler, ok := vm.handlers[opcode]; ok {
			handler(vm)
			vm.pc++
		} else {
			log.Fatalf("Error: Unknown opcode %v\n", opcode)
		}
	}

	// clean up the final value on the stack
	if len(vm.stack) > 0 {
		vm.pop()
	}
}
