#ifndef API_ROBOT_H
#define API_ROBOT_H


/**************************************************************/
/* Motors                                                     */
/**************************************************************/

/*
 * Struct for changing motor speed
 * id: the motor id (0 for left motor or 1 for right motor)
 * speed: the motor speed (Only the last 6 bits are used. Ranges from 0 to 63)
 */
typedef struct
{
  unsigned char id;
  unsigned char speed;
} motor_cfg_t;

/*
 * Sets motor speed.
 * Parameter:
 *   motor: pointer to motor_cfg_t struct containing motor id and motor speed
 * Returns:
 *   * 0, OK
 *   * -1 Invalid Motor
 *   * -2 Invalid Speed
 */
int set_motor_speed(motor_cfg_t* motor);


/**************************************************************/
/* Sonars                                                     */
/**************************************************************/

/*
 * Reads one of the sonars.
 * Parameter:
 *   sonar_id: the sonar id (ranges from 0 to 15).
 * Returns:
 *   * >0 Distance of the selected sonar
 *   * -1 Invalid ID
 */
int read_sonar(unsigned char sonar_id);



/**************************************************************/
/* Timer                                                      */
/**************************************************************/

/*
 * Reads the system time.
 * Parameter:
 *   None
 * Returns:
 *   System time (your variable counted by GPT hardware)
 */
unsigned int get_time();

/*
 * Sets the system time.
 * Parameter:
 *   t: the new system time. (Sets your variable counted by GPT hardware, to value t)
 */
void set_time(unsigned int t);

#endif // API_ROBOT_H
