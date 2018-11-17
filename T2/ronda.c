#include "api_robot2.h"

void ronda(unsigned int* distancias);
void virar1();
void virar2();

int qtdTempo = 0;

void _start(void)
{
  unsigned int distancias[16];
  ronda(distancias);
}

void ronda(unsigned int* distancias) {
  int i;
  motor_cfg_t motor0;
  motor0.id = 0;
  motor0.speed = 25;

  motor_cfg_t motor1;
  motor1.id = 1;
  motor1.speed = 25;

  set_motor_speed(&motor0);
  set_motor_speed(&motor1);

	for(i = 0; i < 500;i++){
		distancias[3]=read_sonar(3);
			distancias[3]=read_sonar(3);

		if (qtdTempo == 50)
			qtdTempo = 0;
			virar1();
		else
			qtdTempo++;
	}
	motor0.speed=0;
	motor1.speed=0;
	set_motor_speed(&motor0);
	set_motor_speed(&motor1);
	distancias[3]=read_sonar(3);
	
}

void virar1() {
  motor_cfg_t motor0;
  int i;
  motor0.id = 0;
  motor0.speed = 25;

  motor_cfg_t motor1;
  motor1.id = 1;
  motor1.speed =0;
  set_motor_speed(&motor0);
  set_motor_speed(&motor1);

  for(i = 0; i < 9000;i++);

  motor0.speed = 25;
  motor0.speed = 25;
  set_motor_speed(&motor0);
  set_motor_speed(&motor1);
}

void virar2() {
  motor_cfg_t motor0;
  int i;
  motor0.id = 0;
  motor0.speed = 25;

  motor_cfg_t motor1;
  motor1.id = 1;
  motor1.speed =0;
  set_motor_speed(&motor0);
  set_motor_speed(&motor1);

  for(i = 0; i < 9000;i++);

  motor0.speed = 25;
  motor0.speed = 25;
  set_motor_speed(&motor0);
  set_motor_speed(&motor1);
}
