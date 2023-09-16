.include "src/defs.s"

// Funcion que interpreta un comando
// In: r0 --> cadena a interpretar
// Devuelve: r0 == 0 --> comando ok
//  ERR_NON_VALID error en la instruccion
//  ERR_PARSE error en el parseo de una expresion

.global interpreta
interpreta:
        stmdb sp!, {r4-r10, lr} // Para poder modificar registros --> salvaguardamos todos!
        sub sp,sp, #TAM_STRING  // Reservamos espacio en la pila para una variable auxilar tipo cadena de tamaño TAM_STRING 
        mov r10, #0             // r10 tiene el codigo de error. Antes de salir de la función lo copiaremos a r0 para retornar dicho valor

        bl ignora_espacios        
        mov r4, r0     		// r4 tiene el comando a interpretar sin espacios al principio

        bl strlen
        cmp r0,#0
        beq f_interpr // Si la cadena está vacía, retornamos

        // Nota: Para facilitar interpretacion de evaluacion de registros --> guardamos el puntero a los registros en una var global
        ldr r5, =registros_virtuales


comprueba_help:
        // Comparamos con los comandos llamando a starts_with o strcmp (ver utils.s y auxiliar.c, respectivamente)

        // Ejemplo strcmp
        mov r0, r4              //r4 tiene la direccion del primer elemento que no es espacio
        ldr r1, =cmd_help	//vemos si es help
        bl strcmp
        cmp r0, #0		//r0=0 es que las cadenas son identicas
        beq ej_help

        //Esto no me furula   
        @ mov r0, r4
        @ ldr r1, =cmd_set_r      
        @ bl strcmp
        @ cmp r0, #0              //r0=0 es que las cadenas son identicas
        @ beq ej_set_vr

        // Comando set vr con starts with
        mov r0, r4
        ldr r1, =cmd_set_r	//compruebo que la instruccion es set vr
        bl starts_with
        cmp r0, #1		// r0=1 es que empieza por set vr
        beq ej_set_vr

        // cCmando set int con starts with
        mov r0, r4
        ldr r1, =cmd_set_int	//primero vemos si el comando empieza por set int
        bl starts_with
        cmp r0, #1		// r0=1 es que empieza por set int
        beq ej_set_int
         
        // Comando input vr con starts with
        mov r0, r4
        ldr r1, =cmd_input	//primero vemos si el comando empieza por input
        bl starts_with
        cmp r0, #1		// r0=1 es que empieza por input
        beq ej_input_vr

        // Comando print con starts with
        mov r0, r4
        ldr r1, =cmd_print	//primero vemos si el comando empieza por print
        bl starts_with
        cmp r0, #1		// r0=1 es que empieza por print
        beq ej_print

        //Comando list reg con starts with
        mov r0, r4              //vemos si el comando empieza por list
        ldr r1, =cmd_lista_reg
        bl starts_with
        cmp r0, #1		// r0=1 es que empieza por list
        beq ej_list_reg

        //Comando pause con starts with
        mov r0, r4
        ldr r1, =cmd_pause	//primero vemos si el comando empieza por input
        bl starts_with
        cmp r0, #1		// r0=1 es que empieza por set r
        beq ej_pause

        b error_cmd   // Si no hemos podido interpretar el comando --> devolvemos código de error
		
ej_help:
        ldr r0, =mensaje_ayuda
        bl printString
        b f_interpr


ej_set_vr:
        // ejemplo: set vr9=44

        add r0, r4, #6  //r0 apunta justo a despues de vr, osea al numero de registro
        bl atoi         //r0 tiene la cadena convertida a int del registro a mostrar
        add r1, r4, #8  // r1 apunta al valor que guardaremos en el registro
        mov r6, r0
        mov r0, r1      //pasa la cadena del valor a int
        bl atoi
        str r0,[r5, r6, lsl#2]  //esta instruccion hace r0 -> [(r6 * 4) + r5 ]
                                //multiplicamos r6 * 4 porque cada registro ocupa 4 bytes
                                //se lo sumamos a r5 que tiene la direccion de memoria de los registros virtuales
                                //ahi es sonde guardamos el valor, que esta en r0

        b f_interpr

ej_input_vr:
        // ejemplo: input vr0

        mov r0, r4      //carga en r0 la direccion del comando introducido
        bl strlen       //devuelve la longitud del comando por r0
        cmp r0, #9      //el comando no debe tener longitud mayor de 9 para asegurarnos de que el registro es del 0 al 9
        bne error_cmd

        add r0, r4, #8  //r0 apunta justo a despues de vr, osea al numero de registro
        bl atoi         //devuelve la cadena convertida en int
        mov r6, r0

        mov r0, #'\n'
        bl write_uart

        mov r7, #0      //r7 va a ser el contador de caracteres

leer:   bl read_uart    //leemos por teclado

        cmp r0, #'\n'   //si se introduce un intro se termina
        beq fin_leer
        cmp r0, #'\r'
        beq fin_leer

        cmp r0, #8      //comprueba si se ha introducido un backspace (num 8 en ascii)
        beq gestiona_back

        strb r0, [sp, r7]  //inserta en la pila + contador de caracteres lo leido en read_uart
        add r7, r7, #1
        bl write_uart   //imprime por pantalla el caracter tecleado
        b leer

fin_leer: 
        mov r8, #0      //carga en r8 un 0 para ponerlo en la pila
                        //atoi para de leer cuando se encuentra un 0
        strb r8, [sp, r7]

        mov r0, #'\n'
        bl write_uart

        mov r0, sp      //carga en r0 la direccion de la pila
        bl atoi         //la devuelva en formato int

        str r0, [r5, r6, lsl#2] //guarda lo devuelto por atoi en el registro que estaba guardado en r6
        b f_interpr


gestiona_back:
      cmp r7, #0        //compara el contador de caracteres r7 con cero
      beq leer          //si es cero vuelve a leer el caracter en input

      bl write_uart     //imprime el backspace, osea que el cursor apunta ahora al caracter anterior
      
      mov r0, #' '
      bl write_uart     //imprime un espacio en el caracter que queremos borrar
      
      mov r0, #8
      bl write_uart     //imprime de nuevo un backspace para que el cursor apunte al espacio
      
      sub r7, r7, #1    //decrementa el contador de caracteres en una unidad
      b leer


ej_print:
        ldrb r6, [r4, #6]       //cargo en r6 lo que hay despues del espacio

        cmp r6, #'v'            //si es una vr va al comando de imprimir registro
        beq ej_print_reg

        cmp r6, #'\"'           //si son unas comillas va al comando de imprimir String
        beq ej_print_string

        b error_cmd             //si no es ni vr ni "--> error comando



ej_print_reg:
        // ejemplo: print vr9
        mov r0, r4              //carga en r0 la direccion del comando introducido (esta en r4)
        bl strlen               //la funcion devuelve la longitud del comando
        cmp r0, #9              //el comando no debe tener longitud mayor de 9, para asegurarnos que el registro es del 0 al 9
        bne error_cmd

        //interpreta el numero de reg
        add r0, r4, #8          //carga en r0 la direccion que apunta al numero del registro en el comando
        bl atoi                 //devuelve el numero en modo int
                                // r0 tiene el numero de registro a mostrar
        ldr r0, [r5, r0, lsl#2] //carga en r0 el valor en memoria del registro virtual que nos ha devuelto el atoi
        bl printInt             //imprime el valor del registro

        mov r0, #'\n'
        bl write_uart           //salto de linea estetico

        b f_interpr

ej_print_string:
        // ejemplo: print "hola"

        add r1, r4, #7          //carga en r1 la direccion de despues de las comillas

        mov r7, r1              //guarda esa direccion
        
        mov r0, #'\"'
        bl find                 //devuelve por r0 la pos de las comillas, empieza a contar por cero

        mov r1, r7              //porque r1 tiene basura despues de llamar al find

        add r8, r1, r0          //r8 apunta a las comillas del fnal

        mov r6, #0
        strb r6, [r8]           //sobre-escribe el fin de linea donde estaban las comillas

        mov r0, r7              //pone de nuevo la direccion a partir de la cual va a imprimir

        bl printString          //imprime el String

        mov r0, #'\n'           //salto de linea estetico
        bl write_uart

        b f_interpr

//POSIBLES PREGUNTAS DE EXAMEN

ej_list_reg:
        mov r7, #10     //contador de registros
        mov r6, r5

bucle_list:
        cmp r7, #0
        beq f_interpr
        ldr r0, [r6]    //carga en r0 el contenido de la direccion de memoria de los registros
        bl printInt
        mov r0, #'\n'
        bl write_uart
        add r6, r6, #4
        sub r7, r7, #1
        
        b bucle_list

        b f_interpr

ej_pause:
        ldr r0, =mensaje_pausa  //imprime el mensaje de pausa
        bl printString

        bl read_uart            //nos quedamos infinitamente leyendo por teclado
        mov r0, #'\n'
        bl write_uart           //salto de linea estetico

        b f_interpr

ej_set_int:
        ldr r6, =var_cont
        
        add r4, r4, #5 //r4 apunta al nombre de la variable
        mov r1, r4
        mov r9, r1 //salvaguardamos r1 para despues en el strncpy, pq r1 es un registro inestable-ERROR RESUELTO
        mov r0, #'='
        bl find        //r0: entra el char =, r1: entra la direccion de la cadena (r4)
                       //r0: sale la posicion del char =
        mov r2, r0
        mov r4, r0     //salvaguardamos la posicion del = pq r2 y r0 son registros inestables-ERR RES
        ldr r7, [r6]   //cargamos en r7 el contador de variables creadas
        mov r8, #16
        mul r8, r7, r8 //en r8 tendremos 16*nºvariables creadas y se lo sumaremos al bufferInt
        ldr r0, =buffer_int
        add r0, r0, r8
        mov r1, r9
        bl strncpy     //r0: la cadena destino es el bufferInt, r1: la cad origen era r4+5
                       //r2: entra la posicion del =, r0: sale la direccion de la cad copiada

        add r4, r4, #1  //r4 ahora es la posicion del primer digito del valor
        add r9, r9, r4  //r9 ahora apunta al primer digito del valor
        mov r0, r9
        bl atoi
        mov r1, r0 //r1 tiene el valor en forma de int
        ldr r0,=buffer_int
        add r0, r0, r8
        add r0, r0, #12 //cargamos en r0 el buffer +16·nºvarContadas + 12 para llegar a la region donde
                        //pondremos el valor de la variable que marca el usuario
        str r1, [r0]    //guardamos en la region de memoria anterior el valor int

        ldr r0, [r6]
        add r0, r0, #1
        str r0, [r6] //aumentamos en una unidad el contador de variables

        b f_interpr

error_cmd:
        mov r10, #ERR_NON_VALID
        b f_interpr


f_interpr:
        mov r0, r10                  // Copiamos el codigo de error en r0, que guarda el valor de retorno
        add sp, #TAM_STRING         // Liberamos la variable auxiliar
        ldmia sp!, {r4-r10, pc}


.end
