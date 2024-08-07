package ast

type SymbolType struct {
	Name string
}

func (T SymbolType) _type() {}

type ArrayType struct {
	Underlying Type
}

func (T ArrayType) _type() {}
