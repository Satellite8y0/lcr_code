#include "temperature.h"

#include <stdio.h>
#include <stdint.h>
#include "iot_i2c.h"
#include "iot_errno.h"

void temperature_init(void) 
{
    uint32_t ret = 0;
    uint8_t send_config[2] = {TEMP_SENSOR_CONFIG, 0X00};
    uint32_t send_config_len = 1;

    
    IoTI2cWrite(TEMP_I2C_PORT, TEMP_SENSOR_WRITE_ADDR, send_config, 1);
    printf("temperature init success!\r\n");
}

float temperature_read(void)
{
    float temperature = 0;
    uint8_t data[2] = {0};


    IoTI2cWrite(TEMP_I2C_PORT, TEMP_SENSOR_WRITE_ADDR, (uint8_t[]){TEMP_SENSOR_DATA}, 1);
    IoTI2cRead(TEMP_I2C_PORT, TEMP_SENSOR_READ_ADDR, data, 2);
    
    temperature = ((uint16_t)data[0] << 8 | data[1]) * 0.00390625;
    printf("raw temperature: %.2f\r\n", temperature);
    return temperature;
}