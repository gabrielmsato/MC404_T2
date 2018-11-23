#include "api_robot2.h"

void busca_parede(int* distancias);
void segue_parede(int* distancias, int sonar);
void corrigir1();
void corrigir2();
void virar1();
void virar2();


void _start(void){
  int distancias[16];

  while(1){
    busca_parede(distancias);
  }
}

void busca_parede(int* distancias) {
  int i, parede=0, sonar=-1;

  motor_cfg_t motor0;
  motor0.id = 0;
  motor0.speed = 8;
  set_motor_speed(&motor0);

  motor_cfg_t motor1;
  motor1.id = 1;
  motor1.speed = 8;
  set_motor_speed(&motor1);
	for(i=0;i<7;i++){
		distancias[i] = read_sonar(i);
	}
  
  while (parede==0) {
			distancias[0] = read_sonar(0);
			distancias[3] = read_sonar(3);
			distancias[4] = read_sonar(4);
			distancias[7] = read_sonar(7);
			if(distancias[3]<=800){
				virar1();
				motor1.speed = 8;
				set_motor_speed(&motor1);
			}
			if(distancias[4]<=800){
				virar2();			
				motor0.speed = 8;
				set_motor_speed(&motor0);
			}
			if(distancias[0]<=800){
				segue_parede(distancias,0);
			}
			if(distancias[7]<=800){
				segue_parede(distancias,7);
			}
		}
  }

void segue_parede(int* distancias, int sonar) {
	int i;
	motor_cfg_t motor1;
  motor1.id = 1;
  motor1.speed = 0;
  set_motor_speed(&motor1);
  
	motor_cfg_t motor0;
  motor0.id = 0;
  motor0.speed = 0;
  set_motor_speed(&motor0);
  for(i=0;i<1000000000;i++){
	}
	for(i=0;i<1000000000;i++){
	}
}

void corrigir1() {}

void corrigir2() {}

void virar1() {
	int i;
	motor_cfg_t motor1;
  motor1.id = 0;
  motor1.speed = 0;
  set_motor_speed(&motor1);
  for(i=0;i<1000000000;i++){
	}
}
void virar2() {
	int i;
	motor_cfg_t motor0;
  motor0.id = 1;
  motor0.speed = 0;
  set_motor_speed(&motor0);
  for(i=0;i<1000000000;i++){
	}
}
