#include "api_robot2.h"

void busca_parede(int* distancias);
void segue_parede(int* distancias, int sonar,int dist);
void corrigir1(int sonar, int dist);
void corrigir2(int sonar, int dist);
void virar1();
void virar2();


void _start(void){
  int distancias[16];

  while(1){
    busca_parede(distancias);
  }
}

void busca_parede(int* distancias) {
  int i;

  motor_cfg_t motor0;
  motor0.id = 0;
  motor0.speed = 20;
  set_motor_speed(&motor0);

  motor_cfg_t motor1;
  motor1.id = 1;
  motor1.speed = 20;
  set_motor_speed(&motor1);
	for(i=0;i<7;i++){
		distancias[i] = read_sonar(i);
	}
  
  while (1) {
			distancias[0] = read_sonar(0);
			distancias[3] = read_sonar(3);
			distancias[4] = read_sonar(4);
			distancias[7] = read_sonar(7);
			if(distancias[3]<=1200){
				virar2();
				set_motor_speed(&motor1);
				set_motor_speed(&motor0);
			}else if(distancias[4]<=1200){
				virar1();			
				set_motor_speed(&motor1);
				set_motor_speed(&motor0);
			}else if(distancias[0]<=1200){
				segue_parede(distancias,0,distancias[0]);
			}else	if(distancias[7]<=1200){
				segue_parede(distancias,7,distancias[7]);
			}
		}
  }

void segue_parede(int* distancias, int sonar,int dist) {
	int i;
	while(1){
		distancias[0] = read_sonar(0);
		distancias[3] = read_sonar(3);
		distancias[4] = read_sonar(4);
		distancias[7] = read_sonar(7);
		if(distancias[3]<dist || distancias[4]<dist){
			break;
		}
		if(sonar==7){
			if(distancias[7]<dist){
				corrigir1(sonar, dist);
			}else if (distancias[7]>dist) {
				corrigir2(sonar, dist);
			}
		}else{
			if(distancias[0]<dist){
				corrigir2(sonar, dist);
			}else if (distancias[0]>dist) {
				corrigir1(sonar,dist);
			}
		}
	}
}

void corrigir1(int sonar, int dist) {
	int distancia = read_sonar(sonar);
	motor_cfg_t motor;
	if(sonar=0){
		motor.id=1;
	}else{
		motor.id=0;
	}
	motor.speed= 18;
	set_motor_speed(&motor);
	while(dist>distancia){
		distancia = read_sonar(sonar);
	}
	motor.speed= 20;
	set_motor_speed(&motor);
}

void corrigir2(int sonar, int dist) {
	int distancia = read_sonar(sonar);
	motor_cfg_t motor;
	if(sonar=0){
		motor.id=1;
	}else{
		motor.id=0;
	}
	motor.speed= 22;
	set_motor_speed(&motor);
	while(dist<distancia){
		distancia = read_sonar(sonar);
	}
	motor.speed= 20;
	set_motor_speed(&motor);
	
}

void virar1() {
	int i;
	motor_cfg_t motor1;
  motor1.id = 0;
  motor1.speed = 0;
  set_motor_speed(&motor1);
  for(i=0;i<10000000;i++){
	}
}
void virar2() {
	int i;
	motor_cfg_t motor0;
  motor0.id = 1;
  motor0.speed = 0;
  set_motor_speed(&motor0);
  for(i=0;i<10000000;i++){
	}
}
