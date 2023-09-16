.include "src/defs.s"

.text

.globl _start
_start:     		ldr pc,reset_handler_d		// Exception vector
					ldr pc,undefined_handler_d
					ldr pc,swi_handler_d
					ldr pc,prefetch_handler_d
					ldr pc,data_handler_d
					ldr pc,unused_handler_d
					ldr pc,irq_handler_d
					ldr pc,fiq_handler_d

reset_handler_d:    .word reset_handler
undefined_handler_d:.word hang
swi_handler_d:      .word swi_handler
prefetch_handler_d: .word hang
data_handler_d:     .word hang
unused_handler_d:   .word hang
irq_handler_d:      .word hang
fiq_handler_d:      .word hang

// SWI handler routine.............................................
reset_handler:		
                    mov r0,#0x10000				// Copy exception vector
					mov r1,#0x00000
					ldmia r0!,{r2,r3,r4,r5,r6,r7,r8,r9}
					stmia r1!,{r2,r3,r4,r5,r6,r7,r8,r9}
					ldmia r0!,{r2,r3,r4,r5,r6,r7,r8,r9}
					stmia r1!,{r2,r3,r4,r5,r6,r7,r8,r9}
					msr cpsr_c,#0xD1			// FIQ 110 10001
					ldr sp,=FIQ_STACK_TOP
					msr cpsr_c,#0xD2			// IRQ 110 10010
					ldr sp,=IRQ_STACK_TOP
					msr cpsr_c,#0xD3			// SVC 110 10011
					ldr sp,=SVC_STACK_TOP
					msr cpsr_c,#0xD7			// ABT 110 10111
					ldr sp,=ABT_STACK_TOP
					msr cpsr_c,#0xDB			// UND 110 11011
					ldr sp,=UND_STACK_TOP
					msr cpsr_c,#0xD0			// USER 110 10000
					ldr sp,=SYS_STACK_TOP
					b main						// start main
    
.global hang
hang:				b hang
				
// declaracion de punteros a cadenas.............................

str_swi:			.asciz "swi "
msg_error:			.asciz "Parametro Desconocido"	//de C3
msg_spsr:			.asciz "Contenido spsr: "
msg_irq_on:			.asciz "Se habilita irq.\t"
msg_irq_off:		.asciz "Se deshabilita irq.\t"
msg_fiq_on:			.asciz "Se habilita fiq.\t"
msg_fiq_off:		.asciz "Se deshabilita fiq.\t"
                                
.align

// SWI handler routine...........................................

// TODO: Añadir aqui el codigo de C3
cad_param_desc: .asciz "Parametro desconocido \n"
cad_aux: 		.asciz ": "

.align

//Modifico el swi_handler para imprimir lo que me pide el C3

swi_handler: 		stmfd sp!,{r0-r12, lr}		//le paso todos los registros posibles 

					ldr r5,[lr,#-4]				//mueve a r5 la instruccion anterior
					bic r5,r5,#0xff000000		//pone a cero los bits que esten a 1 por param, que en este caso FF = 1111 1111
												//esto se hace para quedarse solo con el num de que se le pasa
					
					cmp r5, #9
					bhi swi_param_des // el numero es > 9 sin signo

					mov r0, #'r'
					bl write_uart

					add r0, r5, #'0' //asciz del numero en cuestion
					bl write_uart

					ldr r0, =cad_aux //dos puntos asi monos
					bl printString

					ldr r0, [sp, r5, lsl#2] //cargo de la pila el contenido del registro (numero) que pide el usuario
											//esta instruccion literalmente hace [(r5 * 4) + sp ] -> r0 porque cada registro ocupa 4 bytes
					bl printInt

					mov r0, #'\n'
					bl write_uart

					b fin_swi_handler

swi_error:		
					ldr r0,=msg_error	//pone el mensaje de error
					bl printString
					mov r0,#'\n'		//enter
					bl write_uart
					b fin_swi_handler

swi_param_des:		ldr r0, =cad_param_desc
					bl printString

fin_swi_handler:	ldmfd sp!,{r0-r12, pc}^

				//TODO: añadir codigo de C4 (para parte opcional 8)


muestra_spsr:		stmfd sp!,{lr}
					ldr r0,=msg_spsr
					bl printString
					mrs r0,spsr
					bl printHex
					mov r0,#'\ '		//enter
					bl write_uart
					mrs r0,spsr
					bl printBin
					mov r0,#'\n'		//enter
					bl write_uart
					ldmfd sp!,{pc}

.end
