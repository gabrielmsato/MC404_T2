.org 0x0
.section .iv,"a"
.data

	SYSTEM_TIME: .word 0
	CALLBACK_QTD: .word 0
	ALARM_QTD: .word 0

_start:

interrupt_vector:
    b RESET_HANDLER

.org 0x08
	b SVC_HANDLER

.org 0x18
    b IRQ_HANDLER

.org 0x100
.text

RESET_HANDLER:
	
	.set MAIN,			0x77812000
	@ Valores e enderecos do GPT
	.set GPT_CR, 		0x53FA0000
	.set GPT_PR, 		0x53FA0004
	.set GPT_OCR1, 		0x53FA0010
	.set GPT_IR, 		0x53FA000C
	.set GPT_SR, 		0x53FA0008
	.set TIME_SZ,		50

	@ Valores e enderecos do GPIO
	.set DR,			0x53F84000
	.set GDIR, 			0x53F84004
	.set GDIR_msk,		0b01111100000000000011111111111111
	.set PSR, 			0x53F84008
	.set MAX_ALARMS,	0x8
	.set MAX_CALLBACKS,	0x8	


    @ Zera o contador do sistema
    ldr r2, =SYSTEM_TIME
    mov r0, #0
    str r0, [r2]

    @ Zera o contador de callbacks
    ldr r2, =CALLBACK_QTD
    mov r0, #0
    str r0, [r2]

    @ Zera o contador de alarmes
    ldr r2, =ALARM_QTD
    mov r0, #0
    str r0, [r2]

    @Faz o registrador que aponta para a tabela de interrupções apontar para a tabela interrupt_vector
    ldr r0, =interrupt_vector
    mcr p15, 0, r0, c12, c0, 0


    @ Incializando pilhas em seus modos ------------------------------
    @ Ajustando a pilha do modo IRQ.
    msr  CPSR_c, #0x12
    LDR sp, =IRQ_STACK

    @ Ajustando a pilha do modo SVC
    msr  CPSR_c, #0x13
    LDR sp, =SVC_STACK

    @ Ajustando a pilha do modo SYSTEM 
    msr CPSR_c, #0x1F
    LDR sp, =SYS_STACK


    @ Configurando o GPT ----------------------------------
    @ Habilita clock_src e o configura como periférico escrevendo em GPT_CR 0x41
    LDR r2, =GPT_CR
    MOV r1, #0x41
    STR r1, [r2]

    @ Zera GPT_PR
    LDR r2, =GPT_PR
    MOV r1, #0
    STR r1, [r2]

    @ Escreve em GPT_OCR1 o valor de TIME_SZ (até quanto o contador vai contar)
    LDR r2, =GPT_OCR1
    MOV r1, #TIME_SZ
    STR r1, [r2]

    @ Habilita a interrupcao Output Compare Channel 1 gerada com GPT_OCR1
    LDR r2, =GPT_IR
    MOV r1, #1
    STR r1, [r2]

    
    @ Configurando o GPIO ----------------------------------
    @ Configura a direcao dos pinos entrada/saida
    LDR r2, =GDIR
    MOV r1, #GDIR_msk
    STR r1, [r2]

    @ Zera as entradas e saidas dos pinos
    LDR r2, =DR
    MOV r1, #0
    STR r1, [r2]


	SET_TZIC:
	    @ Constantes para os enderecos do TZIC
	    .set TZIC_BASE,             0x0FFFC000
	    .set TZIC_INTCTRL,          0x0
	    .set TZIC_INTSEC1,          0x84 
	    .set TZIC_ENSET1,           0x104
	    .set TZIC_PRIOMASK,         0xC
	    .set TZIC_PRIORITY9,        0x424

	    @ Liga o controlador de interrupcoes
	    @ R1 <= TZIC_BASE

	    ldr	r1, =TZIC_BASE

	    @ Configura interrupcao 39 do GPT como nao segura
	    mov	r0, #(1 << 7)
	    str	r0, [r1, #TZIC_INTSEC1]

	    @ Habilita interrupcao 39 (GPT)
	    @ reg1 bit 7 (gpt)

	    mov	r0, #(1 << 7)
	    str	r0, [r1, #TZIC_ENSET1]

	    @ Configure interrupt39 priority as 1
	    @ reg9, byte 3

	    ldr r0, [r1, #TZIC_PRIORITY9]
	    bic r0, r0, #0xFF000000
	    mov r2, #1
	    orr r0, r0, r2, lsl #24
	    str r0, [r1, #TZIC_PRIORITY9]

	    @ Configure PRIOMASK as 0
	    eor r0, r0, r0
	    str r0, [r1, #TZIC_PRIOMASK]

	    @ Habilita o controlador de interrupcoes
	    mov	r0, #1
	    str	r0, [r1, #TZIC_INTCTRL]

	    @instrucao msr - habilita interrupcoes
	    msr  CPSR_c, #0x13       @ SUPERVISOR mode, IRQ/FIQ enabled


    @ Inicia o modo usuario--------------------------------------
    msr CPSR_c, #0x10
    LDR r0, =MAIN
    MOV pc, r0

@-------------------------------------------------------------------------------
IRQ_HANDLER:
	@ Informa que a interrupcao foi capturada
    LDR r2, =GPT_SR
    MOV r1, #0x1
    STR r1, [r2]

    @ Incrementa o contador
    ldr r2, =SYSTEM_TIME
    LDR r0, [r2]
    ADD r0, r0, #1
    str r0, [r2]

    @Retorno tem que subtrair 4 de pc
    SUB lr, lr, #4
    MOVS pc, lr

SVC_HANDLER:

.data
	IRQ_STACK: .skip 1024
	SVC_STACK: .skip 1024
	SYS_STACK: .skip 1024