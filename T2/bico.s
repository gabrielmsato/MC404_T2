.global set_motor_speed
.global read_sonar
.global get_time
.global set_time

.text
.align 4


@ Codigo 21
@ unsigned short read_sonar(unsigned char sonar_id);
read_sonar:
	stmfd sp!, {r7, lr}

	@ Fazendo a syscall
	MOV r7, #21
	SVC 0x0

	ldmfd sp!, {r7, pc}

@ Codigo 20
@ void set_motor_speed(motor_cfg_t* motor);
set_motor_speed:
	stmfd sp!, {r7, lr}

	@ Extraindo o valor da struct
	LDRB r1, [r0]
	LDRB r2, [r0, #1]

	@ Fazendo a syscall
	MOV r0, r1
	MOV r1, r2
	MOV r7, #20
	SVC 0x0

	ldmfd sp!, {r7, pc}

@ Codigo 17
@ void get_time(unsigned int* t);
get_time:
	stmfd sp!, {r4, r7, lr}

	@ Salvando o endereco do retorno em r4
	MOV r4, r0

	@ Fazendo a syscall
	MOV r7, #17
	SVC 0x0

	@ Salvando no endereco do ponteiro o retorno
	STR r0, [r4]

	ldmfd sp!, {r4, r7, pc}


@ Codigo 18
@ void set_time(unsigned int t);
set_time:
	stmfd sp!, {r7, lr}

	@ Fazendo a syscall
	MOV r7, #18
	SVC 0x0

	ldmfd sp!, {r7, pc}
