#include "api_robot2.h"

void busca_parede(unsigned int* distancias);
// void segue_parede(unsigned int* distancias);
void corrigir1();
void corrigir2();
void virar1();
void virar2();


void _start(void)
{
  unsigned int distancias[16];
  busca_parede(distancias);
}

void busca_parede(unsigned int* distancias) {
  int i;

  motor_cfg_t motor0;
  motor0.id = 0;
  motor0.speed = 25;

  motor_cfg_t motor1;
  motor1.id = 1;
  motor1.speed = 25;

  set_motor_speed(&motor0);
  set_motor_speed(&motor1);

  while (distancias[3] > 600 && distancias[4] > 600) {
    distancias[3] = read_sonar(3);
    distancias[4] = read_sonar(4);
  }

  motor0.speed = 0;
  set_motor_speed(&motor0);
  set_motor_speed(&motor1);
  for(i = 0; i < 9000;i++);

  motor0.speed = 25;
  motor1.speed = 25;
  set_motor_speed(&motor0);
  set_motor_speed(&motor1);
}
//
// void segue_parede(unsigned int* distancias) {
//
//   register_proximity_callback(0, 500, corrigir1);
//   register_proximity_callback(15, 500, corrigir2);
//
//   register_proximity_callback(3, 600, virar1);
//   register_proximity_callback(4, 600, virar2);
//   while(1);
// }

void corrigir1() {
  motor_cfg_t motor0;
  int i;
  motor0.id = 0;
  motor0.speed = 25;

  motor_cfg_t motor1;
  motor1.id = 1;
  motor1.speed =10;

  set_motor_speed(&motor0);
  set_motor_speed(&motor1);

  for(i = 0; i < 5000;i++);

  motor0.speed = 25;
  motor0.speed = 25;
  set_motor_speed(&motor0);
  set_motor_speed(&motor1);
}

void corrigir2() {
  motor_cfg_t motor0;
  int i;
  motor0.id = 0;
  motor0.speed = 25;

  motor_cfg_t motor1;
  motor1.id = 1;
  motor1.speed =10;

  set_motor_speed(&motor0);
  set_motor_speed(&motor1);

  for(i = 0; i < 5000;i++);

  motor0.speed = 25;
  motor0.speed = 25;
  set_motor_speed(&motor0);
  set_motor_speed(&motor1);
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
