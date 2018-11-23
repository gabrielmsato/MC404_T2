#include "api_robot2.h"

void ronda(int* distancias);
void virar1();
void virar2();

int qtdTempo = 0;
int timeSystem=0;


void _start(void)
{
	int distancias[16];
  //ronda(distancias);
  while (1){
    ronda(distancias);
	}
}

void ronda(int* distancias) {
  motor_cfg_t motor0;
  motor0.id = 0;
  motor0.speed = 20;

  motor_cfg_t motor1;
  motor1.id = 1;
  motor1.speed = 20;

  set_motor_speed(&motor0);
  set_motor_speed(&motor1);

  set_time(0);
  get_time(&timeSystem);
  while (timeSystem < 1000) {
    get_time(&timeSystem);
    distancias[3]=read_sonar(3);
    distancias[4]=read_sonar(4);
    if(distancias[3]<=1000){
			virar2();  
			set_motor_speed(&motor0);
			set_motor_speed(&motor1);
		}else if(distancias[4]<=1100){
			virar1();			
		  set_motor_speed(&motor0);
			set_motor_speed(&motor1);
		}
		
		get_time(&timeSystem);
  }
  
  virar1();

}

void virar1() {
  motor_cfg_t motor0;
  motor_cfg_t motor1;

  motor0.id = 0;
  motor0.speed = 0;

  motor1.id = 1;
  motor1.speed = 25;

  set_motor_speed(&motor0);
  set_motor_speed(&motor1);

  set_time(0);
  get_time(&timeSystem);
  while (timeSystem < 100) {
    get_time(&timeSystem);
  }
  set_time(0);
}

void virar2() {
  motor_cfg_t motor0;
  motor_cfg_t motor1;

  motor0.id = 0;
  motor0.speed = 0;

  motor1.id = 1;
  motor1.speed = 25;

  set_motor_speed(&motor0);
  set_motor_speed(&motor1);

  set_time(0);
  get_time(&timeSystem);
  while (timeSystem < 70) {
    get_time(&timeSystem);
  }
  set_time(0);
}
