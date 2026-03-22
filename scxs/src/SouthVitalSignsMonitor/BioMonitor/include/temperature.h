#ifndef __TEMPERATURE_H__
#define __TEMPERATURE_H__

#define TEMP_I2C_PORT EI2C0_M2
#define TEMP_SENSOR_WRITE_ADDR 0x4C
#define TEMP_SENSOR_READ_ADDR 0x4C
#define TEMP_SENSOR_DATA 0x00
#define TEMP_SENSOR_CONFIG 0x01

void temperature_init(void);
float temperature_read(void);

#endif