.global set_motor_speed
@ .global set_motors_speed
.global read_sonar
@ .global read_sonars
@ .global register_proximity_callback
@ .global add_alarm
.global get_time
.global set_time

.text
.align 4


@ Codigo 16
@ unsigned short read_sonar(unsigned char sonar_id);
read_sonar:
	stmfd sp!, {r7, lr}

	@ Fazendo a syscall
	MOV r7, #21
	SVC 0x0

	ldmfd sp!, {r7, pc}

@ void read_sonars(int start, int end, unsigned int* distances);
@ read_sonars:
@ 	stmfd sp!, {r4, r7, lr}
@
@ 	MOV r4, r0
@ 	read_beg:
@ 		CMP r4, r1
@ 		BHI read_end
@
@ 		@ Fazendo a syscall
@ 		MOV r0, r4
@ 		MOV r7, #16
@ 		SVC 0x0
@
@ 		@ Salvar r0
@ 		STR r0, [r2]
@ 		ADD r2, r2, #4
@
@ 		ADD r4, r4, #1
@ 		B read_beg
@ 	read_end:
@
@ 	ldmfd sp!, {r4, r7, pc}


@ Codigo 17
@ void register_proximity_callback(unsigned char sensor_id, unsigned short dist_threshold, void (*f)());
@ register_proximity_callback:
@ 	stmfd sp!, {r7, lr}
@
@ 	@ Fazendo a syscall
@ 	MOV r7, #17
@ 	SVC 0x0
@
@ 	ldmfd sp!, {r7, pc}


@ Codigo 18
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


@ Codigo 19
@ void set_motors_speed(motor_cfg_t* m1, motor_cfg_t* m2);
@ set_motors_speed:
@ 	stmfd sp!, {r4, r5, r7, lr}
@ 	@ Extraindo o valor da struct
@ 	LDRB r2, [r0, #1]
@ 	LDRB r3, [r1, #1]
@
@ 	@ Fazendo a syscall
@ 	MOV r0, r2
@ 	MOV r1, r3
@ 	MOV r7, #19
@ 	SVC 0x0
@
@ 	ldmfd sp!, {r4, r5, r7, pc}


@ Codigo 20
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


@ Codigo 21
@ void set_time(unsigned int t);
set_time:
	stmfd sp!, {r7, lr}

	@ Fazendo a syscall
	MOV r7, #18
	SVC 0x0

	ldmfd sp!, {r7, pc}


@ Codigo 22
@ void add_alarm(void (*f)(), unsigned int time);
@ add_alarm:
@ 	stmfd sp!, {r7, lr}
@
@ 	@ Fazendo a syscall
@ 	MOV r7, #22
@ 	SVC 0x0
@
@ 	ldmfd sp!, {r7, pc}
