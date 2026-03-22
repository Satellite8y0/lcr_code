#ifndef MAX30102_H
#define MAX30102_H

#include <blood_pressure.h>

#include <stdint.h>
#include <stdbool.h>
#include "ohos_init.h"
#include "cmsis_os2.h"
#include "iot_i2c.h"

#define MAX30102_ADDRESS          0x57 // 7-bit I2C Address
#define I2C_IDX                  0    // RK2206 I2C interface index

// Register addresses
#define MAX30102_INTSTAT1        0x00
#define MAX30102_INTSTAT2        0x01
#define MAX30102_INTENABLE1      0x02
#define MAX30102_INTENABLE2      0x03
#define MAX30102_FIFOWRITEPTR    0x04
#define MAX30102_FIFOOVERFLOW    0x05
#define MAX30102_FIFOREADPTR     0x06
#define MAX30102_FIFODATA        0x07
#define MAX30102_FIFOCONFIG      0x08
#define MAX30102_MODECONFIG      0x09
#define MAX30102_PARTICLECONFIG  0x0A
#define MAX30102_LED1_PULSEAMP   0x0C
#define MAX30102_LED2_PULSEAMP   0x0D
#define MAX30102_PROXINTTHRESH   0x30
#define MAX30102_REVISIONID      0xFE
#define MAX30102_PARTID          0xFF

// Mode configuration
#define MAX30102_MODE_REDONLY    0x02
#define MAX30102_MODE_REDIRONLY  0x03
#define MAX30102_MODE_MULTILED   0x07

// Interrupt flags
#define MAX30102_INT_A_FULL_ENABLE   0x80
#define MAX30102_INT_DATA_RDY_ENABLE 0x40

// FIFO configuration
#define MAX30102_SAMPLEAVG_1     0x00
#define MAX30102_SAMPLEAVG_2     0x20
#define MAX30102_SAMPLEAVG_4     0x40
#define MAX30102_SAMPLEAVG_8     0x60
#define MAX30102_SAMPLEAVG_16    0x80
#define MAX30102_SAMPLEAVG_32    0xA0

// Sample rate configuration
#define MAX30102_SAMPLERATE_50   0x00
#define MAX30102_SAMPLERATE_100  0x04
#define MAX30102_SAMPLERATE_200  0x08
#define MAX30102_SAMPLERATE_400  0x0C
#define MAX30102_SAMPLERATE_800  0x10
#define MAX30102_SAMPLERATE_1000 0x14
#define MAX30102_SAMPLERATE_1600 0x18
#define MAX30102_SAMPLERATE_3200 0x1C

// Pulse width configuration
#define MAX30102_PULSEWIDTH_69   0x00
#define MAX30102_PULSEWIDTH_118  0x01
#define MAX30102_PULSEWIDTH_215  0x02
#define MAX30102_PULSEWIDTH_411  0x03

// ADC range configuration
#define MAX30102_ADCRANGE_2048   0x00
#define MAX30102_ADCRANGE_4096   0x20
#define MAX30102_ADCRANGE_8192   0x40
#define MAX30102_ADCRANGE_16384  0x60

// Multi-LED mode configuration
#define SLOT_RED_LED             0x01
#define SLOT_IR_LED              0x02

// Structure to hold sensor data
// 在现有结构体后增加
typedef struct {
    uint32_t red;
    uint32_t ir;
    BloodPressure_t blood_pressure; // 新增血压数据
} max30102_data_t;


// Function prototypes
bool max30102_begin(void);
void max30102_soft_reset(void);
void max30102_shutdown(void);
void max30102_wakeup(void);
void max30102_set_led_mode(uint8_t mode);
void max30102_set_adc_range(uint8_t adc_range);
void max30102_set_sample_rate(uint8_t sample_rate);
void max30102_set_pulse_width(uint8_t pulse_width);
void max30102_set_pulse_amplitude_red(uint8_t amplitude);
void max30102_set_pulse_amplitude_ir(uint8_t amplitude);
void max30102_set_fifo_average(uint8_t samples);
void max30102_enable_fifo_rollover(void);
void max30102_clear_fifo(void);
void max30102_setup(uint8_t power_level, uint8_t sample_average, uint8_t led_mode, 
                   uint8_t sample_rate, uint8_t pulse_width, uint8_t adc_range);
bool max30102_get_raw_data(max30102_data_t *data);
uint8_t max30102_read_part_id(void);
uint8_t max30102_read_revision_id(void);

#endif // MAX30102_H