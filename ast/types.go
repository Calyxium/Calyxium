package ast

type SymbolType struct {
	Value string
}

func (t SymbolType) _type() {}

type FunctionType struct {
	Parameters []Type
	ReturnType Type
}

func (t FunctionType) _type() {}

type ListType struct {
	Underlying Type
}

func (t ListType) _type() {}
