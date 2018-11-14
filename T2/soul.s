.org 0x0
.section .iv,"a"

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

	@ Valores e enderecos do GPT
	.set GPT_CR, 		0x53FA0000
	.set GPT_PR, 		0x53FA0004
	.set GPT_OCR1, 		0x53FA0010
	.set GPT_IR, 		0x53FA000C
	.set GPT_SR, 		0x53FA0008
	.set TIME_SZ,		200

	@ Valores e enderecos do GPIO
	.set DR,			0x53F84000
	.set GDIR, 			0x53F84004
	.set GDIR_msk,		0xFFFC003E
	.set PSR, 			0x53F84008
	.set MAX_ALARMS,	0x8
	.set MAX_CALLBACKS,	0x8

	.set MAIN,			0x77802000
	.set IRQ_STACK, 	0x77816000
	.set SVC_STACK,		0x77818000
	.set SYS_STACK,		0x77820000


    @ Zera o contador do sistema
    ldr r2, =SYSTEM_TIME
    mov r0, #0
    str r0, [r2]

    @ Zera o contador de callbacks
    ldr r2, =CALLBACK_QTD
    str r0, [r2]

    @ Zera o contador de alarmes
    ldr r2, =ALARM_QTD
    str r0, [r2]

    @Faz o registrador que aponta para a tabela de interrupções apontar para a tabela interrupt_vector
    ldr r0, =interrupt_vector
    mcr p15, 0, r0, c12, c0, 0

    @ Incializando pilhas em seus modos ------------------------------
    @ Ajustando a pilha do modo IRQ.
    msr  CPSR_c, #0xD2
    LDR sp, =IRQ_STACK

    @ Ajustando a pilha do modo SYSTEM
    msr CPSR_c, #0x1F
    LDR sp, =SYS_STACK

    @ Ajustando a pilha do modo SVC
    msr  CPSR_c, #0x13
    LDR sp, =SVC_STACK

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
    LDR r1, =GDIR_msk
    STR r1, [r2]

    @ Zera as entradas e saidas dos pinos
    LDR r2, =DR
    MOV r1, #0x0
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
	stmfd sp!, {r0-r7, lr}

	@ Salvando modo anterior do sistema
	MRS r0, SPSR
	stmfd sp!, {r0}

	msr CPSR_c, #0xD2

	@ Informa que a interrupcao foi capturada
    LDR r2, =GPT_SR
    MOV r1, #0x1
    STR r1, [r2]

    @ Incrementa o contador
    ldr r2, =SYSTEM_TIME
    LDR r0, [r2]
    ADD r0, r0, #1
    STR r0, [r2]

    @ Entrando em modo usuario
    msr CPSR_c, #0x10

    @ Checando alarmes ----------------------------------
	MOV r0, #0 @ Indice do for

	@ Pegando quantidade de alarmes
	LDR r1, =ALARM_QTD
	LDR r1, [r1]

	@ Carrega o vetor de alarmes
	LDR r2, =VET_ALARMES

	MOV r3, #0	@ Indice do contador de alarmes

    @ Vetor de alarmes = endereco_func | tempo (espaco na memoria por posicao = 4 * 2)
    ALARM_CHECK:
    	@ Se indice = qtd, termina
    	CMP r1, r0
    	BEQ ALARM_CHECK_END

    	@ Extrai o tempo do alarme
    	ADD r3, r3, #4
    	LDR r4, [r2, r3]

    	@ Verifica se tempo de sistema = alarme
    	LDR r5, =SYSTEM_TIME
    	LDR r5, [r5]
    	CMP r4, r5
    	BLNE PROX_ALARME

    	@ Indice do ultimo alarme
    	MOV r4, #8
    	MUL r4, r1, r4
    	SUB r4, r4, #8

    	@ Guardando funcao a ser chamada
    	SUB r3, r3, #4
    	LDR r6, [r2, r3]

    	@ Substituindo ultimo alarme pelo executado
    	LDR r7, [r2, r4]
    	STR r7, [r2, r3]
    	ADD r4, r4, #4
    	ADD r3, r3, #4
    	LDR r7, [r2, r4]
    	STR r7, [r2, r3]

    	@ Decrementando qtd alarmes
    	LDR r4, =ALARM_QTD
    	LDR r7, [r4]
    	SUB r7, r7, #1
    	STR r7, [r4]

    	@ Chama a funcao do alarme
    	stmfd sp!, {lr}
	    blx r6
	    ldmfd sp!, {lr}


    	PROX_ALARME:
    	@ Incrementando o for e incrementando o indice do vetor
    	ADD r0, r0, #1
    	ADD r3, r3, #4

    	B ALARM_CHECK
    ALARM_CHECK_END:

    @ Checando callbacks ----------------------------

    MOV r0, #0 @ Indice do for

	@ Pegando quantidade de alarmes
	LDR r1, =CALLBACK_QTD
	LDR r1, [r1]

	@ Carrega o vetor de alarmes
	LDR r2, =VET_CALLBACKS

	MOV r3, #0	@ Indice do contador de alarmes

	@ Vetor de callbacks = id | distancia | funcao
	CALLBACK_CHECK:
    	@ Se indice = qtd, termina
    	CMP r1, r0
    	BEQ CALLBACK_CHECK_END

    	@ Extrai id do sonar
    	MOV r4, r0
    	LDR r0, [r2, r3]

    	@ Empilha registradores caller save
    	stmfd sp!, {r1-r3}

    	@ Chama interrupcao svc para ler sonar
    	MOV r7, #16
    	svc 0x0

    	@ Desempilha registradores caller save
    	ldmfd sp!, {r1-r3}

    	@ Retorna valor antigo de r0
    	MOV r5, r0
    	MOV r0, r4

    	@ Extrai o limiar de distancia e compara com valor lido
    	ADD r3, r3, #4
    	LDR r4, [r2, r3]
    	CMP r4, r5
    	BLHI PROX_CALLBACK

    	@ Indice da ultima callback
    	MOV r4, #12
    	MUL r4, r1, r4
    	SUB r4, r4, #12

    	@ Guardando funcao a ser chamada
    	ADD r3, r3, #4
    	LDR r6, [r2, r3]

    	@ Substituindo ultima callback pela executada
    	SUB r3, r3, #8
    	LDR r7, [r2, r4]
    	STR r7, [r2, r3]
    	ADD r4, r4, #4
    	ADD r3, r3, #4
    	LDR r7, [r2, r4]
    	STR r7, [r2, r3]
    	ADD r4, r4, #4
    	ADD r3, r3, #4
    	LDR r7, [r2, r4]
    	STR r7, [r2, r3]

    	@ Decrementando qtd callbacks
    	LDR r4, =CALLBACK_QTD
    	LDR r7, [r4]
    	SUB r7, r7, #1
    	STR r7, [r4]

    	@ Chama a funcao da callback
    	stmfd sp!, {lr}
	    blx r6
	    ldmfd sp!, {lr}

    	PROX_CALLBACK:
    	@ Incrementando o for e incrementando o indice do vetor
    	ADD r0, r0, #1
    	ADD r3, r3, #4

    	B CALLBACK_CHECK
    CALLBACK_CHECK_END:

    @ Chama syscall para mudar para modo SUPERVISOR
    MOV r7, #50
    svc 0x0

    @ Muda para o IRQ mode para recuperar modo antigo
    msr CPSR_c, #0xD2

    @ Seta modo antigo do sistema
    ldmfd sp!, {r0}
    msr SPSR, r0

    @Retorno tem que subtrair 4 de lr
	ldmfd sp!, {r0-r7, lr}
    SUB lr, lr, #4
	movs pc, lr


SVC_HANDLER:
	stmfd sp!, {r4, lr}

	@ Salva o modo antigo do programa em r4
	MRS r4, SPSR
	stmfd sp!, {r4}

	@ Comparacoes para determinar qual o tipo de syscall
	CMP r7, #21
	BLEQ READ_SONAR
	@ CMP r7, #17
	@ BLEQ REGISTER_PROXIMITY_CALLBACK
	CMP r7, #20
	BLEQ SET_MOTOR_SPEED
	@ CMP r7, #19
	@ BLEQ SET_MOTORS_SPEED
	CMP r7, #17
	BLEQ GET_TIME
	CMP r7, #18
	BLEQ SET_TIME
	@ CMP r7, #22
	@ BLEQ ADD_ALARM

	@ Syscall utilizada para mudar para SUPERVISOR
	CMP r7, #50
	BNE SVC_HANDLER_END

	@ Desempilhando modo antigo, pois queremos o modo SUPERVISOR
	ADD sp, sp, #4

	@ Retorna para a funcao que chamou em modo SUPERVISOR
	ldmfd sp!, {lr}
    mov pc, lr

	SVC_HANDLER_END:
	@ Retorna ao modo antigo do programa
	ldmfd sp!, {r4}
	MSR SPSR, r4

	ldmfd sp!, {r4, lr}
	movs pc, lr


@ Funcoes do uoli -----------------------------------------------------
.set SPEED_msk, 	0b111111
.set SPEED_DR_msk, 	0b1111111
.set SONAR_msk,		0b1111
.set SONARDIS_msk, 	0b111111111111


@ Escreve nos pinos do motor escolhido uma velocidade
@ Parametros:
@ 	r0 - Id do motor
@	r1 - Velocidade do motor
@ Retorno:
@	r0 - 0 = sucesso / -1 = erro no id do motor / -2 = erro na velocidade

SET_MOTOR_SPEED:
	stmfd sp!, {r4, lr}

	@ Verificando se os parametros sao validos
	CMP r0, #1
	MOVHI r0, #-1	@ ID invalido
	BHI SET_MOTOR_SPEED_END
	CMP r1, #0x3F
	MOVHI r0, #-2	@ Velocidade invalida
	BHI SET_MOTOR_SPEED_END

	@ Extrai apenas os 6 bits menos significativos de r1
	LDR r2, =SPEED_msk
	AND r1, r1, r2

	@ Pegando o valor do registrador DR
	LDR r2, =DR
	LDR r2, [r2]

	@ Verifica qual motor esta sendo utilizado
	CMP r0, #0
	MOVEQ r3, #25
	MOVNE r3, #18

	@ Mascara dos bits relativos ao motor
	LDR r4, =SPEED_DR_msk

	@ Zerando os bits da velocidade do motor
	BIC r2, r2, r4, LSL r3

	@ Inserindo nova velocidade
	ADD r3, r3, #1
	ORR r2, r2, r1, LSL r3
	MOV r4, #1
	SUB r3, r3, #1
	BIC r2, r2, r4, LSL r3	@ Flag MOTOR_WRITE <= 0

	@ Seta os pinos do registrador DR para concluir a operacao
	LDR r3, =DR
	STR r2, [r3]
	MOV r0, #0	@ Retorno correto

	SET_MOTOR_SPEED_END:
		@ Retorna para a SVC_HANDLER
		ldmfd sp!, {r4, pc}


@ Escreve nos pinos dos 2 motores as velocidades
@ Parametros:
@ 	r0 - Velocidade do motor 0
@	r1 - Velocidade do motor 1
@ Retorno:
@	r0 - 0 = sucesso / -1 = erro na velocidade do motor 0 /
@		 -2 = erro na velocidade do motor 1

@ SET_MOTORS_SPEED:
@ 	stmfd sp!, {lr}
@
@ 	@ Verificando se os parametros sao validos
@ 	CMP r0, #0x3F
@ 	MOVHI r0, #-1	@ Velocidade do motor 0 invalida
@ 	BHI SET_MOTORS_SPEED_END
@ 	CMP r1, #0x3F
@ 	MOVHI r0, #-2	@ Velocidade do motor 1 invalida
@ 	BHI SET_MOTORS_SPEED_END
@
@ 	@ Extrai apenas os 6 bits menos significativos de r0 e r1
@ 	LDR r2, =SPEED_msk
@ 	AND r0, r0, r2
@ 	AND r1, r1, r2
@
@ 	@ Pegando o valor do registrador DR
@ 	LDR r2, =DR
@ 	LDR r2, [r2]
@
@ 	@ Mascara dos bits relativos ao motor
@ 	LDR r3, =SPEED_DR_msk
@
@ 	@ Zerando os bits das velocidades dos motores
@ 	BIC r2, r2, r3, LSL #18
@ 	BIC r2, r2, r3, LSL #25
@
@ 	@ Inserindo novas velocidades
@ 	ORR r2, r2, r1, LSL #19
@ 	ORR r2, r2, r0, LSL #26
@ 	MOV r1, #1
@ 	BIC r2, r2, r1, LSL #18	@ Flag MOTOR0_WRITE <= 0
@ 	BIC r2, r2, r1, LSL #25	@ Flag MOTOR1_WRITE <= 0
@
@ 	@ Seta os pinos do registrador DR para concluir a operacao
@ 	LDR r1, =DR
@ 	STR r2, [r1]
@ 	MOV r0, #0	@ Retorno correto
@
@ 	SET_MOTORS_SPEED_END:
@ 		@ Retorna para a SVC_HANDLER
@ 		ldmfd sp!, {pc}

@ Le um sonar especifico
@ Parametros:
@ 	r0 - Id do sonar
@ Retorno:
@	r0 - valor do sonar / -1 = erro do id do sonar

READ_SONAR:
	stmfd sp!, {lr}

	@ Verificando se os parametros sao validos
	CMP r0, #15
	MOVHI r0, #-1	@ Erro no id do sonar
	BHI READ_SONAR_END

	@ Extrai apenas os 4 bits menos significativos de r0
	LDR r1, =SONAR_msk
	AND r0, r0, r1

	@ Pegando o valor do registrador DR
	LDR r2, =DR
	LDR r2, [r2]

	@ Inserindo id do sonar
	BIC r2, r2, r1, LSL #2	@ Zerando os bits do id do sonar
	ORR r2, r2, r0, LSL #2

	@ Flag TRIGGER <= 0
	BIC r2, r2, #0b10

	@ Seta os pinos do registrador DR
	LDR r1, =DR
	STR r2, [r1]

	@ Delay para executar as operacoes
	MOV r4, #4096

	DELAY_SONAR_LOOP1:
		CMP r4, #0
		BEQ DELAY_SONAR_END1
		SUB r4, r4, #1
	B DELAY_SONAR_LOOP1
	DELAY_SONAR_END1:


	@ Flag TRIGGER <= 1
	ORR r2, r2, #0b10
	STR r2, [r1]	@ Seta os pinos do registrador DR

	@ Delay para executar as operacoes
	MOV r4, #4096

	DELAY_SONAR_LOOP2:
		CMP r4, #0
		BEQ DELAY_SONAR_END2
		SUB r4, r4, #1
	B DELAY_SONAR_LOOP2
	DELAY_SONAR_END2:

	@ Flag TRIGGER <= 0
	BIC r2, r2, #0b10
	STR r2, [r1]	@ Seta os pinos do registrador DR

	FLAG_LOOP:
		@ Pegando o valor do registrador DR
		LDR r3, [r1]

		@ Verificando de a FLAG = 1
		AND r3, r3, #1
		CMP r3, #1
		BEQ FLAG_LOOP_END

		@ Delay para executar as operacoes
		MOV r4, #4096

		DELAY_SONAR_LOOP3:
			CMP r4, #0
			BEQ DELAY_SONAR_END3
			SUB r4, r4, #1
		B DELAY_SONAR_LOOP3
		DELAY_SONAR_END3:

	B FLAG_LOOP

	FLAG_LOOP_END:

	@ Pegando o valor do registrador DR
	LDR r3, [r1]

	@ Extraindo o valor retornado do sonar
	LDR r2, =SONARDIS_msk
	AND r3, r3, r2, LSL #6
	MOV r0, r3, LSR #6

	READ_SONAR_END:
		@ Retorna para a SVC_HANDLER
		ldmfd sp!, {pc}


@ Adiciona no vetor de callback um callback
@ Parametros:
@ 	r0 - Id do sonar
@	r1 - Limiar de distancia
@	r2 - Ponteiro para a funcao
@ Retorno:
@	r0 - 0 = sucesso / -1 = numero de callbacks max atingido
@		 -2 = id do sonar invalido
@ Vetor de callbacks = id | distancia | funcao

@ REGISTER_PROXIMITY_CALLBACK:
@ 	stmfd sp!, {r4, lr}
@
@ 	@ Carrega qtd callbacks e compara com o max
@ 	LDR r3, =CALLBACK_QTD
@ 	LDR r3, [r3]
@ 	CMP r3, #MAX_CALLBACKS
@ 	MOVGE r0, #-1	@ Erro na qtd de callbacks
@ 	BGE REGISTER_PROXIMITY_CALLBACK_END
@
@ 	@ Verifica se o id do sonar é valido
@ 	CMP r0, #15
@ 	MOVHI r0, #-2
@ 	BLS REGISTER_PROXIMITY_CALLBACK_END
@
@ 	@ Seta o indice da proxima casa do vetor
@ 	@ Vetor de callbacks = id | distancia | funcao (espaco na memoria por posicao = 4 * 3)
@ 	MOV r4, #12
@ 	MUL r4, r3 ,r4
@
@ 	@ Carrega o vetor de callbacks e salva id do sonar
@ 	LDR r3, =VET_CALLBACKS
@ 	STR r0, [r3, r4]
@
@ 	@ Adiciona a distancia
@ 	ADD r4, r4, #4
@ 	STR r1, [r3, r4]
@
@ 	@ Adiciona o ponteiro da funcao
@ 	ADD r4, r4, #4
@ 	STR r2, [r3, r4]
@
@ 	@ Incremente CALLBACK_QTD
@ 	LDR r2, =CALLBACK_QTD
@ 	LDR r3, [r2]
@ 	ADD r3, r3, #1
@ 	STR r3, [r2]
@
@ 	@ Retorna sucesso na operacao
@ 	MOV r0, #0
@
@ 	REGISTER_PROXIMITY_CALLBACK_END:
@ 		ldmfd sp!, {r4, pc}

@ Retorna o tempo do sistema
@ Retorno:
@	r0 - Valor de SYSTEM_TIME

GET_TIME:
	stmfd sp!, {lr}

	@ Carrega o valor de SYSTEM_TIME em r0
	LDR r0, =SYSTEM_TIME
	LDR r0, [r0]

	ldmfd sp!, {pc}

@ Seta o tempo do sistema
@ Parametros:
@ 	r0 - Tempo do sistema a ser setado

SET_TIME:
	stmfd sp!, {lr}

	@ Seta o tempo passado como parametro em SYSTEM_TIME
	LDR r1, =SYSTEM_TIME
	STR r0, [r1]

	ldmfd sp!, {pc}


@ Adiciona um alarme no sistema
@ Parametros:
@ 	r0 - Ponteiro para funcao a ser chamada
@	r1 - Tempo do alarme
@ Retorno:
@	r0 - 0 = sucesso / -1 = maximo de alarmes atingidos
@		 -2 = tempo menor que tempo atual do sistema

@ ADD_ALARM:
@ 	stmfd sp!, {lr}
@
@ 	@ Carrega qtd alarme e compara com o max
@ 	LDR r2, =ALARM_QTD
@ 	LDR r2, [r2]
@ 	CMP r2, #MAX_ALARMS
@ 	MOVGE r0, #-1	@ Erro na qtd de alarmes
@ 	BGE ADD_ALARM_END
@
@ 	@ Verifica se o tempo do alarme eh maior que o tempo do sistema
@ 	LDR r3, =SYSTEM_TIME
@ 	LDR r3, [r3]
@ 	CMP r3, r1
@ 	MOVLS r0, #-2
@ 	BLS ADD_ALARM_END
@
@ 	@ Seta o indice da proxima casa do vetor
@ 	@ Vetor de alarmes = endereco_func | tempo (espaco na memoria por posicao = 4 * 2)
@ 	MOV r3, #8
@ 	MUL r3, r2 ,r3
@
@ 	@ Carrega o vetor de alarmes e salva endereco_func
@ 	LDR r2, =VET_ALARMES
@ 	STR r0, [r2, r3]
@
@ 	@ Adiciona o tempo do alarme
@ 	ADD r3, r3, #4
@ 	STR r1, [r2, r3]
@
@ 	@ Incremento de ALARM_QTD
@ 	LDR r2, =ALARM_QTD
@ 	LDR r3, [r2]
@ 	ADD r3, r3, #1
@ 	STR r3, [r2]
@
@ 	@ Retorna sucesso na operacao
@ 	MOV r0, #0
@
@ 	ADD_ALARM_END:
@ 		ldmfd sp!, {pc}


.data
	SYSTEM_TIME: .word 0
	CALLBACK_QTD: .word 0
	ALARM_QTD: .word 0


	VET_ALARMES:	.skip 64
	VET_CALLBACKS:	.skip 96
