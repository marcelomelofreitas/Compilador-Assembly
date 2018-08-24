const ZERO = 0
const ONE = 1

var NOME[4]

main:
    MOV ECX, 12
    MOV EDX, ONE
    MOV ECX, ONE

CHECK:
    MUL ECX, ECX
    SUB EAX, EDX
    JP CHECK