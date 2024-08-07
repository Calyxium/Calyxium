package helpers

import (
	"fmt"
	"reflect"
)

func ExpectType[T any](r any) T {
	expectedType := reflect.TypeOf((*T)(nil)).Elem()
	recievedType := reflect.TypeOf(r)

	if expectedType == recievedType {
		return r.(T)
	}

	panic(fmt.Sprintf("Expected %v but recieved %v instead.", expectedType, recievedType))
}
