const ZERO = 0
const ONE = 1

var NOME[4]

main:
    MOV CX, 12
    MOV DX, ONE
    MOV EX, ONE

CHECK:
    MUL EX, AX
    SUB AX, DX
    JP CHECK