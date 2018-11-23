#include "api_robot2.h"

void ronda(unsigned int* distancias);

int qtdTempo = 0;
int timeSystem;


void _start(void)
{
	int distancias[16];
  ronda(distancias);
  while (1)
    ronda(distancias);
}

void ronda(unsigned int* distancias) {
  motor_cfg_t motor0;
  motor0.id = 0;
  motor0.speed = 15;

  motor_cfg_t motor1;
  motor1.id = 1;
  motor1.speed = 15;

  set_motor_speed(&motor0);
  set_motor_speed(&motor1);

  set_time(0);
  get_time(&timeSystem);
  while (timeSystem < 3000) {
    get_time(&timeSystem);
  }
  

  virar1();

}

void virar1() {
  motor_cfg_t motor0;
  motor_cfg_t motor1;

  motor0.id = 1;
  motor0.speed = 30;

  motor1.id = 0;
  motor1.speed = 0;

  set_motor_speed(&motor0);
  set_motor_speed(&motor1);

  set_time(0);
  get_time(&timeSystem);
  while (timeSystem < 500) {
    get_time(&timeSystem);
  }
}