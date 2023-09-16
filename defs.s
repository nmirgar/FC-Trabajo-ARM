.equ TAM_INT, 16                           // Tamaño en memoria de una variable entera (12 para nombre, 4 bytes para valor)
.equ TAM_STRING, 256                       // Max tamano de una string
.equ TAM_BUFFER_VARS, 65536
.equ TAM_NOMBRE, 12
.equ ERROR_INT, 0x80000000                 // Numero muy grande para indicar error al parsear entero
.equ BACKSPACE, 127

// Relacionados con la pila
.equ STACK_TOP, 0x05000000                   // En nuestro systema tenemos 128 M de memoria --> 0x05000000 apunta a la primera no valida
.equ FIQ_STACK_TOP, STACK_TOP 
.equ IRQ_STACK_TOP, STACK_TOP - 0x1000       // 4K para cada pila de modo no usuario
.equ ABT_STACK_TOP, STACK_TOP - 0x2000
.equ UND_STACK_TOP, STACK_TOP - 0x3000
.equ SVC_STACK_TOP, STACK_TOP - 0x4000
.equ SYS_STACK_TOP, STACK_TOP - 0x5000       // El modo usuario podría tener más de 4K

// Aquí definimos los códigos de error (el alumno puede definir varias)
.equ ERR_NON_VALID, 1
.equ ERR_PARSE, 2                        // Error al parsear expresion
.equ ERR_UNKNOWN, 1000                   // This is not an error is to let ejecuta know it should end
