#ifndef HEART_RATE_H
#define HEART_RATE_H

#include <stdint.h>
#include <stdbool.h>

// Heart rate detection functions
bool check_for_beat(int32_t sample);
int16_t average_dc_estimator(int32_t *p, uint16_t x);
int16_t low_pass_fir_filter(int16_t din);
int32_t mul16(int16_t x, int16_t y);

// Variables for heart rate detection
extern int16_t IR_AC_Max;
extern int16_t IR_AC_Min;
extern int16_t IR_AC_Signal_Current;
extern int16_t IR_AC_Signal_Previous;
extern int16_t IR_AC_Signal_min;
extern int16_t IR_AC_Signal_max;
extern int16_t IR_Average_Estimated;
extern int16_t positiveEdge;
extern int16_t negativeEdge;
extern int32_t ir_avg_reg;
extern int16_t cbuf[32];
extern uint8_t offset;

#endif // HEART_RATE_H