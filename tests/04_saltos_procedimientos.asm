# Cubre: beq y bne tomados y no tomados; bne tomado hacia atras
# (bucle); j; jal y jr mediante un procedimiento no hoja que guarda
# $ra en la pila, llama a otro procedimiento y retorna correctamente;
# syscall 11 (impresion) y syscall 10 (fin).

.text
.globl main
main:
    # Bucle: bne se toma dos veces y deja de tomarse al llegar a cero.
    addi  $s0, $zero, 0
    addi  $t0, $zero, 3
loop:
    addi  $s0, $s0, 1
    addi  $t0, $t0, -1
    bne   $t0, $zero, loop

    # beq tomado: debe saltarse la suma de 100.
    beq   $t0, $zero, beq_taken
    addi  $s0, $s0, 100
beq_taken:

    # beq no tomado: se suma 2 y se salta el bloque incorrecto con j.
    addi  $t1, $zero, 1
    beq   $t1, $zero, beq_wrong
    addi  $s0, $s0, 2
    j     after_beq
beq_wrong:
    addi  $s0, $s0, 1000

after_beq:
    # bne no tomado: se suma 4, no 10000.
    bne   $t0, $zero, bne_wrong
    addi  $s0, $s0, 4
    j     after_bne
bne_wrong:
    addi  $s0, $s0, 10000

after_bne:
    # proc_outer no es hoja: guarda $ra antes de llamar a proc_inner.
    jal   proc_outer
    move  $s1, $v0           # proc_outer devuelve 12
    add   $s2, $s0, $s1      # 9 + 12 = 21

    move  $a0, $s0
    jal   print_hex
    move  $a0, $s1
    jal   print_hex
    move  $a0, $s2
    jal   print_hex

    addi  $v0, $zero, 10
    syscall

proc_outer:
    addi  $sp, $sp, -4
    sw    $ra, 0($sp)
    jal   proc_inner
    addi  $v0, $v0, 5
    lw    $ra, 0($sp)
    addi  $sp, $sp, 4
    jr    $ra

proc_inner:
    addi  $v0, $zero, 7
    jr    $ra

# Entrada: $a0 = palabra que se quiere imprimir.
# Imprime ocho digitos hexadecimales en mayusculas y un salto de linea.
print_hex:
    move  $t0, $a0
    addi  $t3, $zero, 8
ph_loop:
    srl   $t1, $t0, 28
    sll   $t0, $t0, 4
    slti  $t2, $t1, 10
    bne   $t2, $zero, ph_digit
    addi  $t1, $t1, 55
    j     ph_emit
ph_digit:
    addi  $t1, $t1, 48
ph_emit:
    move  $a0, $t1
    addi  $v0, $zero, 11
    syscall
    addi  $t3, $t3, -1
    bne   $t3, $zero, ph_loop
    addi  $a0, $zero, 10
    addi  $v0, $zero, 11
    syscall
    jr    $ra
