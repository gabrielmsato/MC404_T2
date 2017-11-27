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

  set_motors_speed(&motor0, &motor1);

  add_alarm(virar, qtdTempo * 100);

  register_proximity_callback(3, 600, virar1);
  register_proximity_callback(4, 600, virar2);

  while(true);
}

void virar() {
  motor_cfg_t motor0;
  motor0.id = 0;
  motor0.speed = 25;

  motor_cfg_t motor1;
  motor1.id = 1;
  motor1.speed =0;
  set_motors_speed(&motor0, &motor1);

  for(i = 0; i < 9000);

  motor0.speed = 25;
  motor0.speed = 25;

  set_motors_speed(&motor0, &motor1);

  if (qtdTempo == 50)
    qtdTempo = 0;
  else 
    qtdTempo++;

  add_alarm(virar, qtdTempo * 100);
}

void virar1() {
  motor_cfg_t motor0;
  motor0.id = 0;
  motor0.speed = 25;

  motor_cfg_t motor1;
  motor1.id = 1;
  motor1.speed =0;
  set_motors_speed(&motor0, &motor1);

  for(i = 0; i < 9000);

  motor0.speed = 25;
  motor0.speed = 25;
  set_motors_speed(&motor0, &motor1);
  register_proximity_callback(3, 600, virar1);
}

void virar2() {
  motor_cfg_t motor0;
  motor0.id = 0;
  motor0.speed = 25;

  motor_cfg_t motor1;
  motor1.id = 1;
  motor1.speed =0;
  set_motors_speed(&motor0, &motor1);

  for(i = 0; i < 9000);

  motor0.speed = 25;
  motor0.speed = 25;
  set_motors_speed(&motor0, &motor1);
  register_proximity_callback(4, 600, virar2);
}