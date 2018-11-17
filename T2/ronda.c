#include "api_robot2.h"

void ronda(unsigned int* distancias);
void virar1(unsigned int* distancias);
void virar2();

int qtdTempo = 0;

void _start(void)
{
	int distancias[16];
  ronda(distancias);
}

void ronda(unsigned int* distancias) {
  int i;
  motor_cfg_t motor0;
  motor0.id = 0;
  motor0.speed = 15;

  motor_cfg_t motor1;
  motor1.id = 1;
  motor1.speed = 15;

  set_motor_speed(&motor0);
  set_motor_speed(&motor1);
	distancias[3]=read_sonar(3);
	while(distancias[3]>=300){
		distancias[3]=read_sonar(3);
		distancias[4]=read_sonar(4);
		distancias[5]=read_sonar(5);
		//if(distancias[3]<300){
			//qtdTempo = 0;
			//virar1(distancias);
		//}
		//if (qtdTempo == 50){
		//	qtdTempo = 0;
		//	virar1(distancias);
			
		//}else{
		//	qtdTempo++;
		//}
	}
	motor0.id=0;
	motor0.speed=0;
	set_motor_speed(&motor0);
	motor1.id=1;
	motor1.speed=0;
	set_motor_speed(&motor1);
	for(i=0;i<300;i++){
	distancias[3]=read_sonar(3);
	}
	
}

void virar1(unsigned int* distancias) {
  motor_cfg_t motor0;
  int i;
  motor0.id = 0;
  motor0.speed = 25;

  motor_cfg_t motor1;
  motor1.id = 1;
  motor1.speed =0;
  set_motor_speed(&motor0);
  set_motor_speed(&motor1);

  while(distancias[3]<300){
	distancias[3]=read_sonar(3);
  }
  distancias[3]=read_sonar(3);
  return;
  
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
