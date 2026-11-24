# Cubre y amplía:
# beq/bne tomados y no tomados, un bne hacia atras (bucle), j, jal y jr.
# compute llama a sum_to_n; sum_to_n es recursiva y guarda/restaura $ra
# y $a0 en la pila, comprobando varios niveles de llamadas anidadas.
# syscall 11 imprime resultados y syscall 10 finaliza.

.text
.globl main
main:
    # compute(5) = 5+4+3+2+1 = 15; compute(0) = 0.
    addi  $a0, $zero, 5
    jal   compute
    move  $s0, $v0

    addi  $a0, $zero, 0
    jal   compute
    move  $s1, $v0

    # Bucle hacia atras: acumula 4+3+2+1 = 10.
    addi  $t0, $zero, 4
    addi  $t1, $zero, 0
loop_sum:
    addu  $t1, $t1, $t0
    addi  $t0, $t0, -1
    bne   $t0, $zero, loop_sum
    move  $s3, $t1            # preserva 10: print_hex usa $t1

    # Firma de ramas: solo se suman 1, 2, 4 y 8 si se decide bien.
    addi  $s2, $zero, 0
    beq   $s1, $zero, beq_taken
    addi  $s2, $s2, 1000
beq_taken:
    addi  $s2, $s2, 1

    # beq no tomado. Si se toma por error, añade 1000.
    beq   $s0, $s1, beq_wrong
    addi  $s2, $s2, 2
    j     after_beq
beq_wrong:
    addi  $s2, $s2, 1000
after_beq:

    # bne tomado.
    bne   $s0, $s1, bne_taken
    addi  $s2, $s2, 1000
bne_taken:
    addi  $s2, $s2, 4

    # bne no tomado.
    bne   $s1, $zero, bne_wrong
    addi  $s2, $s2, 8
    j     after_bne
bne_wrong:
    addi  $s2, $s2, 1000
after_bne:

    # Salto j adicional: la suma erronea debe quedar sin ejecutar.
    j     after_j
    addi  $s2, $s2, 1000
after_j:

    move  $a0, $s0            # 0000000F
    jal   print_hex
    move  $a0, $s1            # 00000000
    jal   print_hex
    move  $a0, $s3            # 0000000A
    jal   print_hex
    move  $a0, $s2            # 0000000F
    jal   print_hex

    addi  $v0, $zero, 10
    syscall

# Wrapper no hoja: guarda $ra porque llama a sum_to_n.
compute:
    addi  $sp, $sp, -4
    sw    $ra, 0($sp)
    jal   sum_to_n
    lw    $ra, 0($sp)
    addi  $sp, $sp, 4
    jr    $ra

# sum_to_n(n): devuelve n + sum_to_n(n-1), con sum_to_n(0)=0.
# Cada nivel conserva tanto $ra como n en su propio marco de pila.
sum_to_n:
    beq   $a0, $zero, sum_base
    addi  $sp, $sp, -8
    sw    $ra, 4($sp)
    sw    $a0, 0($sp)
    addi  $a0, $a0, -1
    jal   sum_to_n
    lw    $t2, 0($sp)
    lw    $ra, 4($sp)
    addi  $sp, $sp, 8
    addu  $v0, $v0, $t2
    jr    $ra
sum_base:
    addi  $v0, $zero, 0
    jr    $ra

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
