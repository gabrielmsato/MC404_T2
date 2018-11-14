#include "api_robot2.h"

void virar();
void virar1();
void virar2();

int qtdTempo = 0;

void _start(void)
{
  unsigned int distancias[16];
  motor_cfg_t motor0;
  motor0.id = 0;
  motor0.speed = 25;

  motor_cfg_t motor1;
  motor1.id = 1;
  motor1.speed = 25;

  set_motor_speed(&motor0);
  set_motor_speed(&motor1);
  while(1);
}

void virar() {
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

  if (qtdTempo == 50)
    qtdTempo = 0;
  else
    qtdTempo++;
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
