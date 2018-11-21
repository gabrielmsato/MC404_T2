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

    @ Zera o contador do sistema
    ldr r2, =SYSTEM_TIME
    mov r0, #0
    str r0, [r2]

    @Faz o registrador que aponta para a tabela de interrupções apontar para a tabela interrupt_vector
    ldr r0, =interrupt_vector
    mcr p15, 0, r0, c12, c0, 0

    @ Configurando o GPT ----------------------------------
    @ Habilita clock_src e o configura como periférico escrevendo em GPT_CR 0x41
    LDR r2, =GPT_CR
    MOV r1, #0x00000041
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
      msr CPSR_c, #0x13       @ SUPERVISOR mode, IRQ/FIQ enabled

    @ Incializando pilhas em seus modos ------------------------------
    @ Ajustando a pilha do modo IRQ.
    msr CPSR_c, #0x12
    LDR sp, =IRQ_STACK

    @ Ajustando a pilha do modo SYSTEM
    msr CPSR_c, #0x1F
    LDR sp, =SYS_STACK

    @ Ajustando a pilha do modo SVC
    msr CPSR_c, #0x13
    LDR sp, =SVC_STACK

    @ Inicia o modo usuario--------------------------------------
    msr CPSR_c, #0x10
    LDR r0, =MAIN
    MOV pc, r0

SVC_HANDLER:
	stmfd sp!, {r4, lr}

	@ Salva o modo antigo do programa em r4
	MRS r4, SPSR
	stmfd sp!, {r4}

	@ Comparacoes para determinar qual o tipo de syscall

	CMP r7, #17
	BLEQ GET_TIME
	CMP r7, #18
	BLEQ SET_TIME
	CMP r7, #20
	BLEQ SET_MOTOR_SPEED
  CMP r7, #21
	BLEQ READ_SONAR

	@ Syscall utilizada para mudar para SUPERVISOR
	CMP r7, #50
	BNE SVC_HANDLER_END

	@ Desempilhando modo antigo, pois queremos o modo SUPERVISOR
	ADD sp, sp, #4

	@ Retorna para a funcao que chamou em modo SUPERVISOR
	ldmfd sp!, {pc}

	SVC_HANDLER_END:
	@ Retorna ao modo antigo do programa
	ldmfd sp!, {r4}
	MSR SPSR, r4

	ldmfd sp!, {r4, lr}
	movs pc, lr

  @-------------------------------------------------------------------------------
  IRQ_HANDLER:
  	stmfd sp!, {r0-r7, lr}

  	@ Salvando modo anterior do sistema
  	MRS r0, SPSR
  	stmfd sp!, {r0}

  	msr CPSR_c, #0x12

  	@ Informa que a interrupcao foi capturada
      LDR r2, =GPT_SR
      MOV r1, #1
      STR r1, [r2]

      @ Incrementa o contador
      ldr r2, =SYSTEM_TIME
      LDR r0, [r2]
      ADD r0, r0, #1
      STR r0, [r2]

      @ Entrando em modo usuario
      msr CPSR_c, #0x10

      @ Chama syscall para mudar para modo SUPERVISOR
      MOV r7, #50
      svc 0x0

      @ Muda para o IRQ mode para recuperar modo antigo
      msr CPSR_c, #0x12

      @ Seta modo antigo do sistema
      ldmfd sp!, {r0}
      msr SPSR, r0

      @Retorno tem que subtrair 4 de lr
  	ldmfd sp!, {r0-r7, lr}
      SUB lr, lr, #4
  	movs pc, lr

@ Escreve nos pinos do motor escolhido uma velocidade
@ Parametros:
@ 	r0 - Id do motor
@	  r1 - Velocidade do motor
@ Retorno:
@	  r0 - 0 = sucesso / -1 = erro no id do motor / -2 = erro na velocidade

SET_MOTOR_SPEED:
	stmfd sp!, {r4, lr}

  msr CPSR_c, #0x1F
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
	MOVEQ r3, #18
	MOVNE r3, #25

	@ Mascara dos bits relativos ao motor
	LDR r4, =SPEED_DR_msk

	@ Zerando os bits da velocidade do motor
	BIC r2, r2, r4, LSL r3

	@ Inserindo nova velocidade
	ADD r3, r3, #1
	ORR r2, r2, r1, LSL r3
	MOV r4, #0x1
	SUB r3, r3, #1
	BIC r2, r2, r4, LSL r3	@ Flag MOTOR_WRITE <= 0

	@ Seta os pinos do registrador DR para concluir a operacao
	LDR r3, =DR
	STR r2, [r3]
	MOV r0, #0	@ Retorno correto

	SET_MOTOR_SPEED_END:
		@ Retorna para a SVC_HANDLER
    msr CPSR_c, #0x13
		ldmfd sp!, {r4, pc}

@ Le um sonar especifico
@ Parametros:
@ 	r0 - Id do sonar
@ Retorno:
@	  r0 - valor do sonar / -1 = erro do id do sonar

READ_SONAR:
	stmfd sp!, {r4, lr}
  msr CPSR_c, #0x1F
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

		@ Verificando se a FLAG = 1
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
	MOV r3, r3, LSR #6
  MOV r0, r3

	READ_SONAR_END:
		@ Retorna para a SVC_HANDLER
    msr CPSR_c, #0x13
		ldmfd sp!, {r4, pc}

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
  msr  CPSR_c, #0x1F
	@ Seta o tempo passado como parametro em SYSTEM_TIME
	LDR r1, =SYSTEM_TIME
	STR r0, [r1]
  msr  CPSR_c, #0x13
	ldmfd sp!, {pc}

.data
.org 0x0
	SYSTEM_TIME: .word 0

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

	.set MAIN,			0x77812000
	.set IRQ_STACK, 	0x77836000
	.set SVC_STACK,		0x77848000
	.set SYS_STACK,		0x77850000 @AUMENTEI 2

  @ Funcoes do uoli -----------------------------------------------------
  .set SPEED_msk, 	0b111111
  .set SPEED_DR_msk, 	0b1111111
  .set SONAR_msk,		0b1111
  .set SONARDIS_msk, 	0b111111111111
