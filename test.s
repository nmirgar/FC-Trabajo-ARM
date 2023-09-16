// Para probar funciones auxiliares, no necesitamos probarlas en el main.s
// Es posible probarlas una por una en un main a parte centrada a tal efecto.
// El proceso de probar cada función (o método) por separado se llama pruebas unitarias del código
// Estos tets de ejemplo sirven para probar la funcion "quita_espacios" que está en "utils.s"
.global main
main:

ldr r0,=test_quita_espacios
bl printString

ldr r0,=aux
ldr r1,=cadena2
bl quita_espacios
bl pintaInfoString

ldr r0,=aux
ldr r1,=cadena2
bl quita_espacios
bl pintaInfoString

ldr r0,=aux
swi #0
ldr r1,=cadena3
bl quita_espacios
swi #0
bl pintaInfoString


ldr r0,=aux
ldr r1,=cadena4
bl quita_espacios
bl pintaInfoString

ldr r0,=msg_cadena
bl printString
ldr r0,=cadena5
bl pintaInfoString

ldr r0,=aux
ldr r1,=cadena5
bl quita_espacios
bl pintaInfoString


loop: b loop

.data

cadena1: .asciz "algo"
cadena2: .asciz "sin_espacios"
cadena3: .asciz "espacios derecha   "
cadena4: .asciz "   espacios izquierda"
cadena5: .asciz "   en los dos lados   "

msg_cadena: .asciz "Usando cadena:"

test_quita_espacios: .asciz "Probando la funcion quita espacios con cadena1-5"
aux: .space 400
